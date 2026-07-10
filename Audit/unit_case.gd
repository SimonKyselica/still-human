class_name UnitCase
extends Resource

## A single unit under review — one "file" in the audit terminal caseload.
## Each unit is authored as a .tres data file so new units/days are just data.

@export var unit_id: String = ""
@export var sector_of_origin: String = ""
@export var model_number: String = ""

## Physical/cognitive degradation, 0–100 percent. Compared against the day's
## directive threshold to decide the expected verdict.
@export_range(0, 100) var degradation: int = 0

## Which shift/day this unit belongs to.
@export var day: int = 1

## The interview transcript, top to bottom.
@export var transcript: Array[DialogueLine] = []

## The verdict the current directive expects for this unit. Used later for
## scoring the player's decision.
@export_enum("APPROVE", "HOLD", "INCINERATE", "FLAG") var correct_verdict: String = "APPROVE"
