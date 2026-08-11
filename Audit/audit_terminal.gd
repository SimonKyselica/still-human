class_name AuditTerminal
extends Control

## Controller for the "Audit Terminal — Unit Review" screen (GDD Fáza B).
##
## Tok jednej jednotky:
##   prečítaj zložku + prepis
##   → voliteľne sa PÝTAJ (FLAG) na nárok, ktorý nesedí so zložkou
##   → uzavri prípad jedným z troch verdiktov
## Po poslednej jednotke sa zmena končí, čím sa posunie denný task list.
##
## AGENT je hráč. Úvodnú otázku kladie vždy tú istú (DayCaseload.opening_question)
## a každý ďalší riadok AGENTa je dôsledok stlačenia FLAG — jednotka sa buď
## opraví, alebo si bude stáť za svojím. Jednotky nikdy nehovoria cez
## DialogueManager; titulky patria Handlerovi na telefóne.

signal verdict_submitted(verdict: String)

const SELECT_HINT := "SELECTED: click one detail on each side to compare them"
const MAIN_SCENE := "res://Main.tscn"
const CASELOAD_PATH := "res://Audit/cases/Day%d/day%d_caseload.tres"
const DATA_ROW_SCENE := "res://Audit/data_row.tscn"

## GDD ich volá CLEAR / HOLD / ESCALATE. FLAG tu zámerne nie je.
const VERDICTS := ["APPROVE", "HOLD", "INCINERATE"]

const CLOCK_WARN_SECONDS := 30
const CLOCK_COL_NORMAL := Color(0.878, 0.639, 0.224)   # amber, as authored in the scene
const CLOCK_COL_WARN := Color(0.851, 0.314, 0.227)     # the same red the meter uses
const REPORT_LINE_TIME := 0.8

const COL_DIM := Color(0.435, 0.435, 0.388)
const COL_OK := Color(0.322, 0.788, 0.659)
const COL_BAD := Color(0.851, 0.314, 0.227)

# Transcript colours, matching the mockup.
const BB_SPEAKER := "6f6f63"
const BB_BODY := "e0a339"
const BB_UNIT := "52c9a8"
const BB_SELECTED := "4a3a18"
const BB_BAD := "d9503a"

# --- Node references (cesty zodpovedajú AuditTerminal.tscn) ---
@onready var _data_rows: VBoxContainer = $Margin/VBox/CaseFile/DataRows
@onready var _transcript: RichTextLabel = $Margin/VBox/Transcript/TranscriptText
@onready var _selected_bar: Label = $Margin/VBox/SelectedBar
@onready var _file_value: Label = $Margin/VBox/StatusBar/FileCol/FileValue
@onready var _directive: VBoxContainer = $Margin/VBox/Directive
@onready var _trust_label: Label = $Margin/VBox/Header/ControlsRow/SignalLabel
@onready var _status_dot: Label = $Margin/VBox/Header/TitleRow/StatusDot
@onready var _shift_value: Label = $Margin/VBox/StatusBar/ShiftCol/ShiftValue
@onready var _overlay: Control = $InstructionsOverlay
@onready var _overlay_text: RichTextLabel = $InstructionsOverlay/InstrMargin/InstrVBox/InstrScroll/InstrText

@export var click_sfx: AudioStream
@export var tick_sfx: AudioStream

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
var _shift_over: bool = false
var _clock_running: bool = false

# --- Stav výsluchu (na jeden prípad) ---
## Odhalené riadky prepisu, každý ako {speaker, text}.
var _revealed: Array[Dictionary] = []
## Nároky, na ktoré sa dá práve kliknúť.
var _active_details: Array[String] = []
## Už zodpovedané kolá — jednotka sa neopakuje.
var _answered: Array[UnitChallenge] = []
var _flags_correct: int = 0
var _flags_wrong: int = 0


func _ready() -> void:
	GameState.start_shift()
	GameState.trust_changed.connect(_on_trust_changed)
	GameState.shift_time_changed.connect(_on_shift_time_changed)
	GameState.shift_expired.connect(_on_shift_expired)
	_overlay.visible = false
	_overlay_text.text = _instructions_bbcode()
	_update_trust_label()
	_load_caseload(GameState.day)


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
	# Authoring typos here are invisible at runtime (a claim simply never becomes
	# clickable), so surface them the moment the day loads.
	for i in _caseload.size():
		var problem := _caseload.get_case(i).validate()
		if problem != "":
			push_warning("AuditTerminal: case %d — %s" % [i + 1, problem])
	_case_index = 0
	_shift_over = false
	_show_directive()
	_display_case(_current_case())
	GameState.begin_shift_clock(_caseload.shift_seconds)
	_clock_running = true


func _show_directive() -> void:
	for c in _directive.get_children():
		if c.name != "DirectiveHeader":
			c.queue_free()
	for line in _caseload.directive_lines:
		var l := Label.new()
		l.text = "▸ " + line
		l.add_theme_color_override("font_color", CLOCK_COL_NORMAL)
		# Veľkosť písma berie z themu (default_font_size), tak ako Rule1/Rule2
		# v scéne — jedno miesto na ladenie a na nastavenie veľkosti textu.
		_directive.add_child(l)


# --- Zobrazenie prípadu -----------------------------------------------------

func _display_case(c: UnitCase) -> void:
	if c == null:
		return
	_build_data_rows(c)
	_file_value.text = "%d / %d" % [_case_index + 1, _caseload.size()]

	_revealed.clear()
	_answered.clear()
	_active_details = c.opening_details.duplicate()
	_flags_correct = 0
	_flags_wrong = 0
	_say("AGENT", _caseload.opening_question)
	_say("UNIT", c.opening_answer)

	_reset_selection()
	_render_transcript()


## Prípady si nesú vlastnú sadu riadkov (UnitCase.fields), tak sa zložka skladá
## za behu — deň 2+ môže pridať riadok bez zásahu do scény.
func _build_data_rows(c: UnitCase) -> void:
	for child in _data_rows.get_children():
		child.queue_free()
		_data_rows.remove_child(child)

	var row_scene: PackedScene = load(DATA_ROW_SCENE)
	for f in c.fields():
		var row: DataRow = row_scene.instantiate()
		row.key = f.key
		row.value_text = f.value
		row.selectable = true
		row.row_clicked.connect(_on_row_clicked)
		_data_rows.add_child(row)


func _selectable_rows() -> Array[DataRow]:
	var list: Array[DataRow] = []
	for child in _data_rows.get_children():
		if child is DataRow:
			list.append(child)
	return list


func _reset_selection() -> void:
	_selected_field = ""
	_selected_detail = ""
	for row in _selectable_rows():
		row.selected = false
	_selected_bar.text = SELECT_HINT
	_selected_bar.add_theme_color_override("font_color", COL_DIM)


# --- Prepis -----------------------------------------------------------------

func _say(speaker: String, text: String) -> void:
	if text.strip_edges() == "":
		return
	_revealed.append({"speaker": speaker, "text": text})


func _render_transcript() -> void:
	var lines: PackedStringArray = []
	for entry in _revealed:
		var speaker: String = entry["speaker"]
		var col := BB_UNIT if speaker == "UNIT" else BB_SPEAKER
		lines.append("[color=#%s]%s[/color]  [color=#%s]%s[/color]" % [
			col, speaker, BB_BODY, _markup_claims(entry["text"])
		])
	_transcript.text = "\n\n".join(lines)
	# Nové kolo výsluchu pribúda naspodu; scroll_following v scéne drží pohľad
	# na poslednej odpovedi, takže dlhý výsluch nerozbije rozloženie panelu.


## Obalí klikateľné nároky do [url]. Text sa prechádza raz zľava doprava, takže
## sa nárok nikdy nemôže nájsť druhý raz vnútri už vloženého BBCode.
func _markup_claims(text: String) -> String:
	# Najdlhšie najskôr: keby bol jeden nárok podreťazcom druhého, vyhrá ten celý.
	var claims := _active_details.duplicate()
	claims.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())

	var out := ""
	var i := 0
	while i < text.length():
		var hit := ""
		for claim in claims:
			if claim != "" and text.substr(i, claim.length()) == claim:
				hit = claim
				break
		if hit == "":
			out += text[i]
			i += 1
			continue
		var shown := "[u]%s[/u]" % hit
		if hit == _selected_detail:
			shown = "[bgcolor=#%s][u]%s[/u][/bgcolor]" % [BB_SELECTED, hit]
		out += "[url=%s]%s[/url]" % [hit, shown]
		i += hit.length()
	return out


# --- Výber / výsluch --------------------------------------------------------

func _on_row_clicked(row: DataRow) -> void:
	_click_sfx()
	_selected_field = row.key.to_upper()
	for r in _selectable_rows():
		r.selected = (r == row)
	_update_selected_bar()


func _on_transcript_meta_clicked(meta: Variant) -> void:
	_selected_detail = str(meta)
	_render_transcript()
	_update_selected_bar()


func _update_selected_bar() -> void:
	_selected_bar.add_theme_color_override("font_color", COL_DIM)
	if _selected_field == "" and _selected_detail == "":
		_selected_bar.text = SELECT_HINT
	elif _selected_field == "":
		_selected_bar.text = "SELECTED: \"%s\" — now pick a row in the CASE FILE" % _selected_detail
	elif _selected_detail == "":
		_selected_bar.text = "SELECTED: %s — now pick a claim in the TRANSCRIPT" % _selected_field
	else:
		_selected_bar.text = "SELECTED: %s  vs  \"%s\"   — press FLAG to question it" % [
			_selected_field, _selected_detail
		]


## FLAG = spýtaj sa jednotky. Vždy sa niečo stane: buď má na to pripravenú
## odpoveď, alebo len potvrdí, že údaj sedí — a to hráča stojí dôveru.
func _on_flag() -> void:
	_click_sfx()
	var c := _current_case()
	if c == null or _shift_over:
		return
	if _selected_field == "" or _selected_detail == "":
		_selected_bar.text = "QUESTION NEEDS TWO PICKS — one in the case file, one in the transcript"
		_selected_bar.add_theme_color_override("font_color", COL_BAD)
		return

	var field := _selected_field
	var ch := c.find_challenge(field, _selected_detail, _answered)

	if ch != null:
		_answered.append(ch)
		_flags_correct += 1
		_say("AGENT", ch.agent_line if ch.agent_line != "" else _default_question(field))
		for line in ch.unit_lines:
			_say("UNIT", line)
		# Zodpovedané nároky prestanú byť klikateľné, nech sa hráč nedá
		# potrestať za to, že sa spýta dvakrát na to isté.
		for d in ch.details:
			_active_details.erase(d)
		for d in ch.new_details:
			if not _active_details.has(d):
				_active_details.append(d)
		var delta := GameState.score_flag(c.unit_id, true)
		_flash_bar("DISCREPANCY CONFIRMED — %s   %+d" % [field, delta], COL_OK)
	else:
		_flags_wrong += 1
		_say("AGENT", _default_question(field))
		_say("UNIT", "My %s is correct as stated." % field.to_lower())
		var delta := GameState.score_flag(c.unit_id, false)
		_flash_bar("NO DISCREPANCY — %s matches the file   %+d" % [field, delta], COL_BAD)

	_reset_selection_keep_bar()
	_render_transcript()


func _default_question(field: String) -> String:
	return "Are you sure your %s is correct?" % field.to_lower()


## Ako _reset_selection, ale nechá v lište výsledok otázky.
func _reset_selection_keep_bar() -> void:
	_selected_field = ""
	_selected_detail = ""
	for row in _selectable_rows():
		row.selected = false


func _flash_bar(text: String, col: Color) -> void:
	_selected_bar.text = text
	_selected_bar.add_theme_color_override("font_color", col)


# --- Verdikty ---------------------------------------------------------------

func _on_approve() -> void: _submit("APPROVE")
func _on_hold() -> void: _submit("HOLD")
func _on_incinerate() -> void: _submit("INCINERATE")


func _submit(verdict: String) -> void:
	_click_sfx()
	var c := _current_case()
	if c == null or _shift_over:
		return

	var helped := c.is_plea(verdict)
	var delta := GameState.score_case(c, verdict, _flags_correct > 0)

	print("[AuditTerminal] unit=%s verdict=%s (expected %s) asked=%d/%d helped=%s  trust %+d -> %d" % [
		c.unit_id, verdict, c.correct_verdict, _flags_correct, _flags_wrong, helped,
		delta, GameState.trust
	])

	verdict_submitted.emit(verdict)

	# The unit's last word. Only faulty units have one.
	if helped and c.reaction_obeyed != "":
		await _show_reaction(c.reaction_obeyed)
	elif c.is_faulty and not helped and c.reaction_refused != "":
		await _show_reaction(c.reaction_refused)

	_next_case()


func _next_case() -> void:
	if _shift_over:
		return
	_case_index += 1
	if _case_index >= _caseload.size():
		if _caseload.unfinishable:
			_await_next_assignment()
			return
		_finish_shift()
		return
	_display_case(_current_case())


func _finish_shift() -> void:
	_shift_over = true
	_clock_running = false
	print("[AuditTerminal] shift complete — %d units, trust %d/%d, helped %d" % [
		_caseload.size(), GameState.trust, GameState.TRUST_MAX, GameState.helped_this_shift
	])
	await _leave_terminal()


# --- Terminal Instructions --------------------------------------------------

func _instructions_bbcode() -> String:
	return "\n".join([
		"[color=#%s]READING A FILE[/color]" % BB_BODY,
		"The CASE FILE is what the company recorded. The TRANSCRIPT is what the unit",
		"says. Your job is to decide whether they agree.",
		"",
		"[color=#%s]ASKING A QUESTION  (FLAG)[/color]" % BB_BODY,
		"Click one row in the case file, then one underlined claim in the transcript,",
		"then press FLAG. You put the discrepancy to the unit and it answers:",
		"it either corrects itself or stands by what it said. That answer is usually",
		"what decides the verdict, so ask before you rule.",
		"  • A question that lands on a real discrepancy:   [color=#%s]+%d trust[/color]" % [
			BB_UNIT, GameState.TRUST_FLAG_CORRECT
		],
		"  • A question about data that already matches:    [color=#%s]%d trust[/color]" % [
			BB_BAD, GameState.TRUST_FLAG_WRONG
		],
		"You may ask as many times as the clock allows.",
		"",
		"[color=#%s]CLOSING A FILE[/color]" % BB_BODY,
		"  APPROVE      the unit passes review",
		"  HOLD         the unit is detained for further review",
		"  INCINERATE   the unit is destroyed",
		"Every file must be closed. Files left open when the shift ends are counted",
		"against you.",
		"",
		"[color=#%s]THE CLOCK[/color]" % BB_BODY,
		"SHIFT TIME keeps running while you read this page.",
		"",
		"[color=#%s]SECTOR CODES[/color]" % BB_BODY,
		"Units state their sector by code. The file records the number.",
		"    1 — PY        6 — ZX",
		"    2 — QL        7 — WS",
		"    3 — XL        8 — LE",
		"    4 — VN        9 — KL",
		"    5 — DY       10 — EX",
	])


func _on_instructions_pressed() -> void:
	_click_sfx()
	if _shift_over:
		return
	_overlay.visible = true
	# Hodiny zámerne bežia ďalej — čítanie pravidiel zmenu nezastaví.
	_set_actions_enabled(false)


func _on_back_pressed() -> void:
	_click_sfx()
	_close_instructions()


## Overlay nič neresetuje, takže sa hráč vracia presne tam, kde bol.
func _close_instructions() -> void:
	if not _overlay.visible:
		return
	_overlay.visible = false
	_set_actions_enabled(not _shift_over and GameState.trust > 0)


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
	_hold_terminal(true)
	_say("UNIT", line)
	_render_transcript()
	await get_tree().create_timer(2.6).timeout
	_hold_terminal(false)


func _set_actions_enabled(on: bool) -> void:
	for b in $Margin/VBox/Actions.get_children():
		if b is Button:
			b.disabled = not on


func _play_lockout() -> void:
	_hold_terminal(true)
	_selected_bar.add_theme_color_override("font_color", COL_BAD)
	for line in LOCKOUT_LINES:
		_selected_bar.text = line
		await get_tree().create_timer(1.4).timeout
	await get_tree().create_timer(1.2).timeout


func _process(delta: float) -> void:
	if _clock_running:
		GameState.tick_shift(delta)


func _on_shift_time_changed(seconds_left: int) -> void:
	_update_clock_label(seconds_left)


func _update_clock_label(seconds_left: int) -> void:
	if _shift_value == null:
		return
	_shift_value.text = "%02d:%02d" % [seconds_left / 60, seconds_left % 60]
	if seconds_left > CLOCK_WARN_SECONDS:
		_shift_value.add_theme_color_override("font_color", CLOCK_COL_NORMAL)
		return
	_shift_value.add_theme_color_override("font_color", CLOCK_COL_WARN)
	if seconds_left > 0:
		_tick_sfx()


func _tick_sfx() -> void:
	if tick_sfx == null:
		return
	AudioManager.play_sound(tick_sfx, AudioManager.BUS_SFX, -8.0, 0.6, 0.0)


func _hold_terminal(on: bool) -> void:
	_clock_running = not on and not _shift_over
	_set_actions_enabled(not on)


func _on_shift_expired() -> void:
	if _shift_over or _caseload == null:
		return
	_shift_over = true
	_clock_running = false
	# Koniec zmeny sa hlási v lište pod prepisom — nesmie ostať schovaný.
	_overlay.visible = false
	_update_clock_label(0)
	_set_actions_enabled(false)

	if _caseload.expiry_mode == "SCRIPTED":
		GameState.pending_ending = GameState.resolve_ending()
		print("[AuditTerminal] scripted expiry — ending = %s" % GameState.pending_ending)
	else:
		await _play_unresolved_report()

	await _leave_terminal()


func _play_unresolved_report() -> void:
	_selected_bar.add_theme_color_override("font_color", CLOCK_COL_WARN)
	var remaining := _caseload.size() - _case_index
	if remaining <= 0:
		_selected_bar.text = "SHIFT ENDED — ALL FILES RESOLVED"
		await get_tree().create_timer(REPORT_LINE_TIME).timeout
		return

	_selected_bar.text = "SHIFT ENDED — %d FILE(S) UNRESOLVED" % remaining
	await get_tree().create_timer(REPORT_LINE_TIME).timeout

	while _case_index < _caseload.size():
		var c := _current_case()
		var delta := GameState.mark_unresolved(c)
		_selected_bar.text = "%s   NO DECISION RECORDED   %+d" % [c.unit_id, delta]
		_case_index += 1
		await get_tree().create_timer(REPORT_LINE_TIME).timeout


func _leave_terminal() -> void:
	if GameState.trust <= 0:
		await _play_lockout()
	GameState.complete_task("terminal")
	GameState.last_player_pos = "PC"
	get_tree().change_scene_to_file(MAIN_SCENE)


func _await_next_assignment() -> void:
	_set_actions_enabled(false)
	_selected_bar.add_theme_color_override("font_color", COL_DIM)
	_selected_bar.text = "FILE SUBMITTED — AWAITING NEXT ASSIGNMENT"


# --- Dev pomôcky ------------------------------------------------------------

func _on_day1_pressed() -> void:
	_load_caseload(1)


func _on_day2_pressed() -> void:
	_load_caseload(2)
