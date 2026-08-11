class_name DayCaseload
extends Resource

@export var day: int = 1
# Pravidlá zobrazené pod "TODAY'S DIRECTIVE", jeden label na položku.
@export var directive_lines: Array[String] = []
@export var cases: Array[UnitCase] = []

## Agent je hráč a pýta sa stále to isté, tak je otázka autorovaná raz na deň,
## nie na každý prípad.
@export_multiline var opening_question: String = \
	"State your sector of origin, model number and unit ID."

@export var shift_seconds: float = 300.0
@export_enum("PENALISE", "SCRIPTED") var expiry_mode = "PENALISE"
@export var unfinishable: bool = false

func size() -> int:
	return cases.size()
	
func get_case(i: int) -> UnitCase:
	if i < 0 or i >= cases.size():
		return null
	return cases[i]
