extends Node

var day: int = 1
var path: String = "" # A alebo B
var vent_blocked: bool = false
var terminal_log: Array = []
var last_player_pos: String = "BED" #- PC, BED, DOOR, PHONE

var schedule: Array[DayTask] = []
var current_task_index: int = 0

signal task_advanced(newTask: DayTask)
signal phase_changed(newPhase: String)
signal day_started(d: int)
signal day_completed(d: int)

func _ready() -> void:
	start_day(day)
	
func start_day(d: int) -> void:
	current_task_index = 0
	schedule = _build_schedule(d)
	day_started.emit(d)
	
	
func _build_schedule(d: int) -> Array[DayTask]:
	var list: Array[DayTask] = []
	#list.append(_task("eat",      "Najedz sa",                  "CHORE"))
	list.append(_task("phone",    "Pick up the phone",           "PHONE"))
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
