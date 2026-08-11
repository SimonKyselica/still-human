class_name UnitChallenge
extends Resource

## One round of questioning inside the audit terminal.
##
## The AGENT is the player. Pressing FLAG with a case-file row and a transcript
## claim selected *asks the unit about it*: if the selection matches this
## challenge, [member agent_line] and [member unit_lines] are appended to the
## transcript and the unit either corrects itself or doubles down.
##
## A challenge can be answered only once per case. Chain them by listing the
## claims the reply introduces in [member new_details] — those become clickable
## and a later challenge can target them (see day 1's 334-QL, which lies twice).

## Case-file rows this challenge accepts, e.g. ["MODEL NUMBER"]. Compared
## case-insensitively against [member DataRow.key]. List several when one
## question covers several rows.
@export var fields: Array[String] = []

## Transcript claims this challenge accepts, e.g. ["PY-1"]. Each must appear
## verbatim in [member UnitCase.opening_answer] or in an earlier challenge's
## [member new_details], otherwise it is never clickable.
@export var details: Array[String] = []

## What the agent says. Leave empty to generate "Are you sure your %s is
## correct?" from the row the player selected — the agent asks the same
## questions every time, so most challenges need no override.
@export_multiline var agent_line: String = ""

## The unit's reply, one entry per transcript line.
@export var unit_lines: Array[String] = []

## Claims inside [member unit_lines] that become clickable after this reply.
@export var new_details: Array[String] = []

## True when the unit corrected itself here. Flavour and design notes only —
## the expected verdict always comes from [member UnitCase.correct_verdict].
@export var corrects: bool = false


## True when [param field] / [param detail] (as selected in the terminal) are
## the pair this challenge is waiting for.
func matches(field: String, detail: String) -> bool:
	return _has(fields, field) and _has(details, detail)


func _has(list: Array[String], value: String) -> bool:
	for entry in list:
		if entry.strip_edges().to_upper() == value.strip_edges().to_upper():
			return true
	return false
