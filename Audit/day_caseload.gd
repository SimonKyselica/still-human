class_name DayCaseload
extends Resource

@export var day: int = 1
# Pravidlá zobrazené pod "TODAY'S DIRECTIVE", jeden label na položku.
@export var directive_lines: Array[String] = []
@export var cases: Array[UnitCase] = []

func size() -> int:
	return cases.size()
	
func get_case(i: int) -> UnitCase:
	if i < 0 or i >= cases.size():
		return null
	return cases[i]
