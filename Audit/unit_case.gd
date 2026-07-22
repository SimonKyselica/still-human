class_name UnitCase
extends Resource


@export var unit_id: String = ""
@export var sector_of_origin: String = ""
@export var model_number: String = ""

## Physical/cognitive degradation, 0–100 percent. Compared against the day's
## directive threshold to decide the expected verdict.
@export_range(0, 100) var degradation: int = 0
@export var day: int = 1
@export var transcript: Array[DialogueLine] = []
@export_enum("APPROVE", "HOLD", "INCINERATE", "FLAG") var correct_verdict: String = "APPROVE"
## Ktorý riadok ZLOŽKY protirečí ktorému nároku v PREPISE.
## Musí sedieť na kľúč DataRow: "UNIT ID", "SECTOR OF ORIGIN",
## "MODEL NUMBER", "DEGRADATION".
@export var contradiction_field: String = ""
@export var contradiction_detail: String = ""

# True, keď zložka a prepis naozaj nesedia. Keď false, flagnutie je vždy chybné.
func has_contradiction() -> bool:
	return contradiction_field != "" and contradiction_detail != ""
