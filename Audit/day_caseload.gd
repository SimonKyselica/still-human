class_name DayCaseload
extends Resource

@export var day: int = 1
# Pravidlá zobrazené pod "TODAY'S DIRECTIVE", jeden label na položku.
@export var directive_lines: Array[String] = []
@export var cases: Array[UnitCase] = []

@export var shift_seconds: float = 300.0
@export_enum("PENALISE", "SCRIPTED") var expiry_mode = "PENALISE"
@export var unfinishable: bool = false

func size() -> int:
	return cases.size()
	
func get_case(i: int) -> UnitCase:
	if i < 0 or i >= cases.size():
		return null
	return cases[i]
