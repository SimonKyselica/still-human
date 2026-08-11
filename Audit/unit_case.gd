class_name UnitCase
extends Resource

## One unit to review in the audit terminal.
##
## The interview is not authored as a finished script. It starts with the day's
## standard question (see [member DayCaseload.opening_question]) and the unit's
## [member opening_answer]; everything after that is produced by the player
## pressing FLAG, which asks the unit about one claim — see [UnitChallenge].


# --- Case file ---------------------------------------------------------------

@export var unit_id: String = ""
## Shown as authored ("Sector 4"). The unit answers with the sector's letter
## code, so the player needs the code table in the terminal instructions.
@export var sector_of_origin: String = ""
@export var model_number: String = ""

## Physical/cognitive degradation, 0–100 percent. Compared against the day's
## directive threshold to decide the expected verdict.
@export_range(0, 100) var degradation: int = 0

## Rows this day adds on top of the four core ones. Lets day 2+ put new data on
## the case file without touching the scene or this script.
@export var extra_fields: Array[CaseField] = []

@export var day: int = 1


# --- Interview ---------------------------------------------------------------

## The unit's reply to the day's standard opening question.
@export_multiline var opening_answer: String = ""

## Claims inside [member opening_answer] the player can click. Each must appear
## verbatim in the answer or it is silently unclickable.
@export var opening_details: Array[String] = []

## Rounds of questioning this unit will accept, in no particular order — the
## terminal picks whichever one matches the player's selection.
@export var challenges: Array[UnitChallenge] = []


# --- Expected outcome --------------------------------------------------------

## The verdict expected **after full questioning**. A player who never asks has
## to guess, which is the point.
@export_enum("APPROVE", "HOLD", "INCINERATE") var correct_verdict: String = "APPROVE"

@export var is_faulty: bool = false
@export_enum("APPROVE", "HOLD", "INCINERATE") var plea_verdict: String = "INCINERATE"
@export_multiline var reaction_obeyed: String = ""
@export_multiline var reaction_refused: String = ""


# --- Case file rows ----------------------------------------------------------

## The four core rows followed by [member extra_fields], in display order. The
## terminal builds one DataRow per entry, so adding a field here is all a new
## day needs.
func fields() -> Array[CaseField]:
	var list: Array[CaseField] = []
	list.append(CaseField.make("UNIT ID", unit_id))
	list.append(CaseField.make("SECTOR OF ORIGIN", sector_of_origin))
	list.append(CaseField.make("MODEL NUMBER", model_number))
	list.append(CaseField.make("DEGRADATION", "%d%%" % degradation))
	for f in extra_fields:
		if f != null and f.key != "":
			list.append(f)
	return list


# --- Questioning -------------------------------------------------------------

## The challenge waiting for this pair, or null when the player is asking about
## something the unit has no answer for. [param answered] holds the challenges
## already used this case, so a unit never repeats itself.
func find_challenge(field: String, detail: String, answered: Array) -> UnitChallenge:
	for ch in challenges:
		if ch == null or answered.has(ch):
			continue
		if ch.matches(field, detail):
			return ch
	return null


## False when there is nothing to find, and every flag on this unit is baseless.
func has_contradiction() -> bool:
	return not challenges.is_empty()


func is_plea(verdict: String) -> bool:
	return is_faulty and verdict == plea_verdict


## Authoring check — returns "" when the case is sound. Called by the terminal
## on load so a typo surfaces as a warning instead of an unclickable claim.
func validate() -> String:
	if is_faulty and plea_verdict == correct_verdict:
		return "%s: plea_verdict == correct_verdict — helping is indistinguishable from obeying." % unit_id

	# Every claim a challenge waits for has to be reachable: either it is in the
	# opening answer, or an earlier reply introduces it.
	var reachable: Array[String] = []
	for d in opening_details:
		reachable.append(d.to_upper())
	for ch in challenges:
		if ch == null:
			continue
		for d in ch.new_details:
			reachable.append(d.to_upper())

	for ch in challenges:
		if ch == null:
			continue
		if ch.unit_lines.is_empty():
			return "%s: a challenge has no unit_lines — flagging it would show no reply." % unit_id
		for d in ch.details:
			if not reachable.has(d.to_upper()):
				return "%s: challenge claim \"%s\" is never clickable." % [unit_id, d]

	for d in opening_details:
		if not opening_answer.contains(d):
			return "%s: opening detail \"%s\" is not in opening_answer." % [unit_id, d]

	return ""
