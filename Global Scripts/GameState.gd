extends Node

var day: int = 1
var path: String = "" # A alebo B
var vent_blocked: bool = false
var terminal_log: Array = []
var last_player_pos: String = "BED" #- PC, BED, DOOR, PHONE

var schedule: Array[DayTask] = []
var current_task_index: int = 0

#How many units were wrong
var shift_mistakes: int = 0

var trust: int = TRUST_START

var helped_units: Array[String] = []
var refused_units: Array[String] = []
var helped_this_shift: int = 0

var pending_ending: String = ""

#shift time
var shift_time_left: float = 0.0
var shift_total: float = 0.0
var shift_unresolved: int = 0

signal trust_changed(new_trust: int, delta: int)
signal trust_depleted()
signal shift_time_changed(seconds_left: int)
signal shift_expired()

var _trust_depleted_fired: bool = false
var _shift_expired_fired: bool = false

@onready var bedsound: AudioStream = preload("res://sfx/bed_stand_up.mp3")

signal task_advanced(newTask: DayTask)
signal phase_changed(newPhase: String)
signal day_started(d: int)
signal day_completed(d: int)

#TRUST FUNCTION
const TRUST_MAX = 100
const TRUST_START = 80

const TRUST_CORRECT_VERDICT := 2
const TRUST_WRONG_VERDICT := -8
const TRUST_HELPED_UNIT := -15      ## obeying a faulty unit's plea
const TRUST_FLAG_CORRECT := 3
const TRUST_FLAG_WRONG := -4

const TRUST_DAILY_RECOVERY := 10
const TRUST_STABLE_MIN := 70
const TRUST_WATCHED_MIN := 35

const GOOD_ENDING_MIN_HELPED := 3

func _ready() -> void:
	start_day(day)
	
func start_day(d: int) -> void:
	current_task_index = 0
	schedule = _build_schedule(d)
	if d > 1:
		add_trust(TRUST_DAILY_RECOVERY, "overnight review")
	day_started.emit(d)
	
	#var duration = bedsound.get_length() 
	#var fadeRect = get_tree().get_first_node_in_group("screen_fader") as ColorRect
	#fadeRect.color = Color(0.0, 0.0, 0.0, 1.0)
	#var tween = create_tween()
	#tween.tween_property(fadeRect, "color:a", 0.0, duration)
	#AudioManager.play_sound(bedsound, AudioManager.BUS_SFX, 0.0, 1.0, 0.01)
	#await get_tree().create_timer(duration).timeout
	
	
func _build_schedule(d: int) -> Array[DayTask]:
	var list: Array[DayTask] = []
	#list.append(_task("eat",      "Najedz sa",                  "CHORE"))
	#list.append(_task("morning_phone",    "Pick up the phone",           "PHONE"))
	list.append(_task("terminal", "Work shift from terminal", "TERMINAL"))
	list.append(_task("phone",    "Pick up the phone",           "PHONE"))
	list.append(_task("sleep",    "Go to bed",                 "SLEEP"))
	return list

func _task(id: String, title: String, phase: String) -> DayTask:
	var t := DayTask.new()
	t.id = id
	t.title = title
	t.phase = phase
	return t
	
func current_task() -> DayTask:
	if current_task_index <0 or current_task_index >=schedule.size():
		return null
	return schedule[current_task_index]

func current_task_id() -> String:
	var t := current_task()
	return t.id if t else ""
func current_phase() -> String:
	var t := current_task()
	return t.phase if t else ""
	
func complete_task(task_id: String) -> void:
	var t := current_task()
	if t == null or t.id != task_id:
		push_warning("complete_task(%s) ignorované — aktívna je %s" % [task_id, current_task_id()])
		return
	var prev_phase := t.phase
	current_task_index +=1
	if(current_task().id == "phone"):
		await get_tree().create_timer(5).timeout
	var nxt := current_task()
	task_advanced.emit(nxt)
	if nxt == null:
		day_completed.emit(day)
	elif nxt.phase != prev_phase:
		phase_changed.emit(nxt.phase)
		
func end_day() ->void:
	day_completed.emit(day)
	advance_day()
	start_day(day)
	last_player_pos = "BED"
	print("Day", day)

func log_decision(candidate_id: String, decision: String, flagged_correctly: bool) -> void:
	terminal_log.append({
		"candidate_id": candidate_id,
		"decision": decision,
		"flagged_correctly": flagged_correctly
	})
	
func advance_day() -> void:
	day += 1
	
func choose_path(chosen: String) -> void:
	path = chosen
	vent_blocked = (chosen == "A")
	
func shift_was_clean() -> bool:
	return shift_mistakes == 0


func add_trust(delta: int, reason: String = "") -> void:
	if delta == 0:
		return
	var before := trust
	trust = clampi(trust + delta, 0, TRUST_MAX)
	var applied := trust - before
	if applied == 0:
		return   # already pinned at 0 or 100
	print("[Trust] %+d -> %d/%d  (%s)" % [applied, trust, TRUST_MAX, reason])
	trust_changed.emit(trust, applied)
	if trust <= 0 and not _trust_depleted_fired:
		_trust_depleted_fired = true
		pending_ending = "DEATH"
		trust_depleted.emit()
		
## Scores one round of questioning, the moment the player asks it. Deliberately
## separate from [method score_case]: folding it into the verdict hid it from
## both the trust meter and the log, and the player never saw that asking a good
## question paid. Returns the delta so the terminal can report it.
func score_flag(unit_id: String, correct: bool) -> int:
	var delta := TRUST_FLAG_CORRECT if correct else TRUST_FLAG_WRONG
	add_trust(delta, "flag %s / %s" % [unit_id, "CORRECT" if correct else "BASELESS"])
	return delta


## Scores the verdict only — flags were already paid for by [method score_flag].
func score_case(c: UnitCase, verdict: String, flagged_correctly: bool = false) -> int:
	var delta := 0

	if c.is_plea(verdict):
		# The player obeyed a faulty unit. The expensive act.
		delta += TRUST_HELPED_UNIT
		if not helped_units.has(c.unit_id):
			helped_units.append(c.unit_id)
		helped_this_shift += 1
	else:
		if c.is_faulty and not refused_units.has(c.unit_id):
			refused_units.append(c.unit_id)
		if verdict == c.correct_verdict:
			delta += TRUST_CORRECT_VERDICT
		else:
			delta += TRUST_WRONG_VERDICT
			shift_mistakes += 1

	log_decision(c.unit_id, verdict, flagged_correctly)
	add_trust(delta, "unit %s / %s" % [c.unit_id, verdict])
	return delta
	
func start_shift() -> void:
	shift_mistakes = 0
	helped_this_shift = 0
	shift_unresolved = 0
	
func trust_band() -> String:
	if trust <= 0:
		return "TERMINATED"
	elif trust >= TRUST_STABLE_MIN:
		return "STABLE"
	elif trust >= TRUST_WATCHED_MIN:
		return "WATCHED"
	return "CRITICAL"
	
func trust_color() -> Color:
	match trust_band():
		"STABLE":
			return Color(0.290, 0.541, 0.427)   # green
		"WATCHED":
			return Color(0.878, 0.639, 0.224)   # amber
		_:
			return Color(0.851, 0.314, 0.227)   # red

func resolve_ending() -> String:
	if pending_ending == "DEATH" or trust <= 0:
		return "DEATH"
	if helped_units.size() >= GOOD_ENDING_MIN_HELPED:
		return "GOOD"
	return "BAD"
	
func route() -> String:
	return 'A' if helped_units.size() > 0 else "B"
	

func begin_shift_clock(seconds: float) -> void:
	shift_total = maxf(seconds, 1.0)
	shift_time_left = shift_total
	_shift_expired_fired = false
	shift_unresolved = 0
	shift_time_changed.emit(int(ceil(shift_time_left)))
	
func tick_shift(delta: float) -> void:
	if _shift_expired_fired or shift_time_left <= 0.0:
		return
	var before := int(ceil(shift_time_left))
	shift_time_left = maxf(shift_time_left - delta, 0.0)
	var now := int(ceil(shift_time_left))
	if now != before:
		shift_time_changed.emit(now)
	if shift_time_left <= 0.0:
		_shift_expired_fired = true
		shift_expired.emit()
		
func mark_unresolved(c: UnitCase) -> int:
	if c == null:
		return 0
	shift_mistakes += 1
	shift_unresolved += 1
	if c.is_faulty and not refused_units.has(c.unit_id):
		refused_units.append(c.unit_id)
	log_decision(c.unit_id, "UNRESOLVED", false)
	var before := trust
	add_trust(TRUST_WRONG_VERDICT, "unresolved %s" % c.unit_id)
	return trust - before


# =============================================================================
# UI SCALE — accessibility (README §10: text size is a requirement, not an extra)
# =============================================================================
#
# Scales every canvas item, so all Control UI grows together while the 3D render
# stays at full resolution. Works because the whole project is laid out in a
# virtual 1920x1080 (display/window/stretch/mode = "canvas_items").
#
# The cap is deliberately low: raising the factor SHRINKS the virtual viewport
# (1920 / 1.15 = 1670 px wide), and the Audit terminal only has ~150 px of
# vertical slack at 1.0. Above ~1.15 its panels start to overflow 1080p. Lift
# the cap only once the transcript can scroll.
const UI_SCALE_MIN := 0.9
const UI_SCALE_MAX := 1.15

var ui_scale: float = 1.0


## Single entry point for the text-size setting. No options menu calls it yet.
func set_ui_scale(factor: float) -> void:
	ui_scale = clampf(factor, UI_SCALE_MIN, UI_SCALE_MAX)
	get_window().content_scale_factor = ui_scale
	print("[UI] scale -> %.2f" % ui_scale)
