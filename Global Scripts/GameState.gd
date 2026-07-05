extends Node

var day: int = 1
var path: String = "" # A alebo B
var vent_blocked: bool = false
var terminal_log: Array = []

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
