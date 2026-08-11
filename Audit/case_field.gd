class_name CaseField
extends Resource

## One "LABEL .......... value" line of a CASE FILE.
##
## The four core fields (UNIT ID, SECTOR OF ORIGIN, MODEL NUMBER, DEGRADATION)
## stay typed exports on [UnitCase] because the directive compares them. This
## resource exists so a day can add rows the earlier days never had — see
## [member UnitCase.extra_fields].
##
## [member key] is what the player selects when flagging, so it must match the
## [member UnitChallenge.fields] entry that challenges it. Comparison is
## case-insensitive.

@export var key: String = ""
@export var value: String = ""


static func make(k: String, v: String) -> CaseField:
	var f := CaseField.new()
	f.key = k
	f.value = v
	return f
