class_name AuditTerminal
extends Control

## Controller for the "Audit Terminal — Unit Review" screen.
## For now it populates the layout from a UnitCase resource and exposes clearly
## named hooks; the day tabs, file navigation, compare mechanic and verdict
## consequences are stubbed and meant to be filled in next.

## Emitted when the auditor issues a verdict on the current unit.
signal verdict_submitted(verdict: String)

const SELECT_HINT := "SELECTED: click one detail on each side to compare them"

@export var current_case: UnitCase

# --- Node references (paths mirror AuditTerminal.tscn) ---
@onready var _row_unit_id: DataRow = $Margin/VBox/CaseFile/DataRows/RowUnitId
@onready var _row_sector: DataRow = $Margin/VBox/CaseFile/DataRows/RowSector
@onready var _row_model: DataRow = $Margin/VBox/CaseFile/DataRows/RowModel
@onready var _row_degradation: DataRow = $Margin/VBox/CaseFile/DataRows/RowDegradation
@onready var _transcript: RichTextLabel = $Margin/VBox/Transcript/TranscriptText
@onready var _selected_bar: Label = $Margin/VBox/SelectedBar
@onready var _file_value: Label = $Margin/VBox/StatusBar/FileCol/FileValue


func _ready() -> void:
	if current_case:
		_display_case(current_case)
	else:
		push_warning("AuditTerminal: no current_case assigned.")


func _display_case(c: UnitCase) -> void:
	_row_unit_id.value_text = c.unit_id
	_row_sector.value_text = c.sector_of_origin
	_row_model.value_text = c.model_number
	_row_degradation.value_text = "%d%%" % c.degradation
	_transcript.text = _build_transcript_bbcode(c)
	_file_value.text = "1 / 3"
	_selected_bar.text = SELECT_HINT


## Renders the transcript as BBCode. Speaker labels are dim; any line with a
## `detail` becomes a clickable [url] so the compare mechanic can hook it later.
func _build_transcript_bbcode(c: UnitCase) -> String:
	var lines: PackedStringArray = []
	for line in c.transcript:
		var body := line.text
		if line.detail != "":
			body = body.replace(
				line.detail,
				"[url=%s][u]%s[/u][/url]" % [line.detail, line.detail]
			)
		lines.append("[color=#6f6f63]%s[/color]  [color=#e0a339]%s[/color]" % [line.speaker, body])
	return "\n\n".join(lines)


# --- Verdict buttons (functional stubs, wired for later) ---
func _on_approve() -> void: _submit("APPROVE")
func _on_hold() -> void: _submit("HOLD")
func _on_incinerate() -> void: _submit("INCINERATE")
func _on_flag() -> void: _submit("FLAG")

func _submit(verdict: String) -> void:
	var who := current_case.unit_id if current_case else "?"
	print("[AuditTerminal] verdict=%s unit=%s" % [verdict, who])
	verdict_submitted.emit(verdict)


# --- Hooks to implement next ---
func _on_day1_pressed() -> void:
	print("[AuditTerminal] day 1 selected")  # TODO: load day 1 caseload

func _on_day2_pressed() -> void:
	print("[AuditTerminal] day 2 selected")  # TODO: load day 2 caseload

## Fires when a clickable transcript detail is clicked (compare mechanic).
func _on_transcript_meta_clicked(meta: Variant) -> void:
	_selected_bar.text = "SELECTED: %s" % str(meta)
	print("[AuditTerminal] detail clicked: ", meta)  # TODO: compare two picks
