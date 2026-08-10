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

signal trust_changed(new_trust: int, delta: int)
signal trust_depleted()

var _trust_depleted_fired: bool = false

@onready var bedsound: AudioStream = preload("res://sfx/bed_stand_up.mp3")

signal task_advanced(newTask: DayTask)
signal phase_changed(newPhase: String)
signal day_started(d: int)
signal day_completed(d: int)

#TRUST FUNCTION
const TRUST_MAX = 100
const TRUST_START = 100

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
	list.append(_task("eat",      "Najedz sa",                  "CHORE"))
	list.append(_task("morning_phone",    "Pick up the phone",           "PHONE"))
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
		
func score_case(c: UnitCase, verdict: String, flag_state: String) -> int:
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

	match flag_state:
		"CORRECT":
			delta += TRUST_FLAG_CORRECT
		"WRONG":
			delta += TRUST_FLAG_WRONG

	log_decision(c.unit_id, verdict, flag_state == "CORRECT")
	add_trust(delta, "unit %s / %s" % [c.unit_id, verdict])
	return delta
	
func start_shift() -> void:
	shift_mistakes = 0
	helped_this_shift = 0
	
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
	
func penalise_unresolved(count: int) -> void:
	if count <= 0:
		return
	shift_mistakes += count
	add_trust(TRUST_WRONG_VERDICT * count, "%d unresolved at time-out" % count)
