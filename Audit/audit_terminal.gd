class_name AuditTerminal
extends Control

## Controller for the "Audit Terminal — Unit Review" screen (GDD Fáza B).
##
## Tok jednej jednotky:
##   prečítaj zložku + prepis
##   → voliteľne FLAG rozpor (jeden výber na KAŽDEJ strane)
##   → uzavri prípad jedným z troch verdiktov
## Po poslednej jednotke sa zmena končí, čím sa posunie denný task list.

signal verdict_submitted(verdict: String)

const SELECT_HINT := "SELECTED: click one detail on each side to compare them"
const MAIN_SCENE := "res://Main.tscn"
const CASELOAD_PATH := "res://Audit/cases/Day%d/day%d_caseload.tres"

## GDD ich volá CLEAR / HOLD / ESCALATE. FLAG tu zámerne nie je.
const VERDICTS := ["APPROVE", "HOLD", "INCINERATE"]

enum FlagState { NONE, CORRECT, WRONG }

# --- Node references (cesty zodpovedajú AuditTerminal.tscn) ---
@onready var _row_unit_id: DataRow = $Margin/VBox/CaseFile/DataRows/RowUnitId
@onready var _row_sector: DataRow = $Margin/VBox/CaseFile/DataRows/RowSector
@onready var _row_model: DataRow = $Margin/VBox/CaseFile/DataRows/RowModel
@onready var _row_degradation: DataRow = $Margin/VBox/CaseFile/DataRows/RowDegradation
@onready var _transcript: RichTextLabel = $Margin/VBox/Transcript/TranscriptText
@onready var _selected_bar: Label = $Margin/VBox/SelectedBar
@onready var _file_value: Label = $Margin/VBox/StatusBar/FileCol/FileValue
@onready var _directive: VBoxContainer = $Margin/VBox/Directive
@onready var _trust_label: Label = $Margin/VBox/Header/ControlsRow/SignalLabel
@onready var _design_notes: CheckBox = $Margin/VBox/Header/ControlsRow/DesignNotesCheck
@onready var _status_dot: Label = $Margin/VBox/Header/TitleRow/StatusDot

@export var click_sfx: AudioStream

const TRUST_FLASH_TIME := 1.6
const LOCKOUT_LINES := [
	"EMPLOYEE REVIEW: TRUST 0/100",
	"TERMINAL ACCESS REVOKED",
	"REMAIN AT YOUR STATION.",
]

var _trust_flash: SceneTreeTimer = null

# --- Stav zmeny ---
var _caseload: DayCaseload
var _case_index: int = 0
var _selected_field: String = ""
var _selected_detail: String = ""
var _flag_state: FlagState = FlagState.NONE


func _ready() -> void:
	for row in _selectable_rows():
		row.selectable = true
		row.row_clicked.connect(_on_row_clicked)
	GameState.start_shift()
	GameState.trust_changed.connect(_on_trust_changed)
	_update_trust_label()
	_load_caseload(GameState.day)


func _selectable_rows() -> Array[DataRow]:
	var list: Array[DataRow] = []
	list.append(_row_unit_id)
	list.append(_row_sector)
	list.append(_row_model)
	list.append(_row_degradation)
	return list


func _current_case() -> UnitCase:
	if _caseload == null:
		return null
	return _caseload.get_case(_case_index)


# --- Caseload ---------------------------------------------------------------

func _caseload_path(d: int) -> String:
	return CASELOAD_PATH % [d, d]

func _load_caseload(d: int) -> void:
	var path := _caseload_path(d)
	if not ResourceLoader.exists(path):
		push_warning("AuditTerminal: no caseload at %s — falling back to day 1." % path)
		path = _caseload_path(1)
	_caseload = load(path) as DayCaseload
	if _caseload == null or _caseload.size() == 0:
		push_error("AuditTerminal: caseload missing or empty (%s)." % path)
		return
	_case_index = 0
	_show_directive()
	_display_case(_current_case())


func _show_directive() -> void:
	for c in _directive.get_children():
		if c.name != "DirectiveHeader":
			c.queue_free()
	for line in _caseload.directive_lines:
		var l := Label.new()
		l.text = "▸ " + line
		l.add_theme_color_override("font_color", Color(0.878, 0.639, 0.224))
		l.add_theme_font_size_override("font_size", 32)
		_directive.add_child(l)


# --- Zobrazenie prípadu -----------------------------------------------------

func _display_case(c: UnitCase) -> void:
	if c == null:
		return
	_row_unit_id.value_text = c.unit_id
	_row_sector.value_text = c.sector_of_origin
	_row_model.value_text = c.model_number
	_row_degradation.value_text = "%d%%" % c.degradation
	_file_value.text = "%d / %d" % [_case_index + 1, _caseload.size()]
	_reset_selection()
	_transcript.text = _build_transcript_bbcode(c)
	_update_design_notes()


func _reset_selection() -> void:
	_selected_field = ""
	_selected_detail = ""
	_flag_state = FlagState.NONE
	for row in _selectable_rows():
		row.selected = false
	_selected_bar.text = SELECT_HINT
	_selected_bar.add_theme_color_override("font_color", Color(0.435, 0.435, 0.388))


func _build_transcript_bbcode(c: UnitCase) -> String:
	var lines: PackedStringArray = []
	for line in c.transcript:
		var body := line.text
		if line.detail != "":
			var shown := "[u]%s[/u]" % line.detail
			if line.detail == _selected_detail:
				shown = "[bgcolor=#4a3a18][u]%s[/u][/bgcolor]" % line.detail
			body = body.replace(line.detail, "[url=%s]%s[/url]" % [line.detail, shown])
		lines.append("[color=#6f6f63]%s[/color]  [color=#e0a339]%s[/color]" % [line.speaker, body])
	return "\n\n".join(lines)


# --- Compare / FLAG ---------------------------------------------------------

func _on_row_clicked(row: DataRow) -> void:
	_click_sfx()
	_selected_field = row.key.to_upper()
	for r in _selectable_rows():
		r.selected = (r == row)
	_update_selected_bar()


func _on_transcript_meta_clicked(meta: Variant) -> void:
	_selected_detail = str(meta)
	_transcript.text = _build_transcript_bbcode(_current_case())
	_update_selected_bar()


func _update_selected_bar() -> void:
	_selected_bar.add_theme_color_override("font_color", Color(0.435, 0.435, 0.388))
	if _selected_field == "" and _selected_detail == "":
		_selected_bar.text = SELECT_HINT
	elif _selected_field == "":
		_selected_bar.text = "SELECTED: \"%s\" — now pick a row in the CASE FILE" % _selected_detail
	elif _selected_detail == "":
		_selected_bar.text = "SELECTED: %s — now pick a claim in the TRANSCRIPT" % _selected_field
	else:
		_selected_bar.text = "SELECTED: %s  vs  \"%s\"   — press FLAG" % [_selected_field, _selected_detail]


func _on_flag() -> void:
	_click_sfx()
	var c := _current_case()
	if c == null:
		return
	if _selected_field == "" or _selected_detail == "":
		_selected_bar.text = "FLAG NEEDS TWO PICKS — one in the case file, one in the transcript"
		return

	var correct := false
	if c.has_contradiction():
		correct = (_selected_field == c.contradiction_field.to_upper()
			and _selected_detail == c.contradiction_detail)

	if correct:
		_flag_state = FlagState.CORRECT
		_selected_bar.text = "CONTRADICTION LOGGED — %s vs \"%s\"" % [_selected_field, _selected_detail]
		_selected_bar.add_theme_color_override("font_color", Color(0.322, 0.788, 0.659))
	else:
		_flag_state = FlagState.WRONG
		_selected_bar.text = "NO DISCREPANCY FOUND — flag dismissed"
		_selected_bar.add_theme_color_override("font_color", Color(0.851, 0.314, 0.227))


# --- Verdikty ---------------------------------------------------------------

func _on_approve() -> void: _submit("APPROVE")
func _on_hold() -> void: _submit("HOLD")
func _on_incinerate() -> void: _submit("INCINERATE")


func _submit(verdict: String) -> void:
	_click_sfx()
	var c := _current_case()
	if c == null:
		return

	var helped := c.is_plea(verdict)
	var delta := GameState.score_case(c, verdict, _flag_text())

	print("[AuditTerminal] unit=%s verdict=%s (expected %s) flag=%s helped=%s  trust %+d -> %d" % [
		c.unit_id, verdict, c.correct_verdict, _flag_text(), helped, delta, GameState.trust
	])

	verdict_submitted.emit(verdict)

	# The unit's last word. Only faulty units have one.
	if helped and c.reaction_obeyed != "":
		await _show_reaction(c.reaction_obeyed)
	elif c.is_faulty and not helped and c.reaction_refused != "":
		await _show_reaction(c.reaction_refused)

	_next_case()



func _flag_text() -> String:
	match _flag_state:
		FlagState.CORRECT:
			return "CORRECT"
		FlagState.WRONG:
			return "WRONG"
		_:
			return "NONE"


func _next_case() -> void:
	_case_index += 1
	if _case_index >= _caseload.size():
		_finish_shift()
		return
	_display_case(_current_case())


func _finish_shift() -> void:
	print("[AuditTerminal] shift complete — %d units, trust %d/%d, helped %d" % [
		_caseload.size(), GameState.trust, GameState.TRUST_MAX, GameState.helped_this_shift
	])

	if GameState.trust <= 0:
		await _play_lockout()

	# Order matters: mark the task done BEFORE changing scene, or DayManager in
	# the room won't see the "phone" task active and the phone never rings.
	GameState.complete_task("terminal")
	GameState.last_player_pos = "PC"
	get_tree().change_scene_to_file(MAIN_SCENE)


# --- Dev pomôcky ------------------------------------------------------------

func _on_day1_pressed() -> void:
	_load_caseload(1)


func _on_day2_pressed() -> void:
	_load_caseload(2)


func _on_design_notes_toggled(_pressed: bool) -> void:
	_update_design_notes()


func _update_design_notes() -> void:
	if _design_notes == null or not _design_notes.button_pressed:
		return
	var c := _current_case()
	if c == null:
		return
	var hint := "expected: %s" % c.correct_verdict
	if c.has_contradiction():
		hint += "   |   contradiction: %s vs \"%s\"" % [c.contradiction_field, c.contradiction_detail]
	else:
		hint += "   |   no contradiction (flagging is wrong)"
	_selected_bar.text = "[DESIGN] " + hint


func _on_design_notes_check_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.

func _click_sfx() -> void:
	AudioManager.play_sound(click_sfx, AudioManager.BUS_SFX, 0.0, 1.0, 0.03)

func _on_trust_changed(_new_trust: int, delta: int) -> void:
	_update_trust_label(delta)


## Repaints the meter. A non-zero delta is shown alongside for a moment, so the
## player connects the drop to the decision they just made.
func _update_trust_label(delta: int = 0) -> void:
	if _trust_label == null:
		return
	var col := GameState.trust_color()
	var txt := "TRUST: %d/%d" % [GameState.trust, GameState.TRUST_MAX]
	if GameState.trust <= 0:
		txt = "TRUST: 0/%d — REVIEW FLAGGED" % GameState.TRUST_MAX
	elif delta != 0:
		txt += "   %+d" % delta
	_trust_label.text = txt
	_trust_label.add_theme_color_override("font_color", col)
	if _status_dot:
		_status_dot.add_theme_color_override("font_color", col)
	if delta != 0:
		_clear_delta_after_delay()


func _clear_delta_after_delay() -> void:
	var t := get_tree().create_timer(TRUST_FLASH_TIME)
	_trust_flash = t
	await t.timeout
	# A newer change came in while we waited — that one owns the label now.
	if _trust_flash != t or not is_inside_tree():
		return
	_update_trust_label()
	
func _show_reaction(line: String) -> void:
	_set_actions_enabled(false)
	_transcript.text += "\n\n[color=#52c9a8]UNIT[/color]  [i]%s[/i]" % line
	await get_tree().create_timer(2.6).timeout
	_set_actions_enabled(true)


func _set_actions_enabled(on: bool) -> void:
	for b in $Margin/VBox/Actions.get_children():
		if b is Button:
			b.disabled = not on
			
func _play_lockout() -> void:
	_set_actions_enabled(false)
	_selected_bar.add_theme_color_override("font_color", Color(0.851, 0.314, 0.227))
	for line in LOCKOUT_LINES:
		_selected_bar.text = line
		await get_tree().create_timer(1.4).timeout
	await get_tree().create_timer(1.2).timeout
