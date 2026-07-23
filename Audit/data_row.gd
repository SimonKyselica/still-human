@tool
class_name DataRow
extends HBoxContainer

## A single "LABEL .................. value" row for the CASE FILE section.
## Left label is dim, right value is amber, and a dotted leader line is drawn
## along the bottom to match the terminal mockup.

signal row_clicked(row: DataRow)

const SELECT_COLOR := Color(0.878, 0.639, 0.224, 1.0)

@export var key: String = "LABEL":
	set(v):
		key = v
		_apply()

@export var value_text: String = "value":
	set(v):
		value_text = v
		_apply()

## Colour of the dotted separator drawn under the row.
@export var line_color: Color = Color(0.29, 0.29, 0.251, 1.0)

@export var selectable: bool  = false:
	set(v):
		selectable = v
		_apply_mouse()
		
var selected: bool = false:
	set(v):
		selected = v
		queue_redraw()

func _ready() -> void:
	resized.connect(queue_redraw)
	_apply_mouse()
	_apply()
	
func _apply_mouse() -> void:
	if not is_node_ready():
		return
	if selectable:
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		mouse_default_cursor_shape = Control.CURSOR_ARROW

func _apply() -> void:
	# Setters can fire during load, before children exist — guard for that.
	if not is_node_ready():
		return
	if has_node("KeyLabel"):
		($KeyLabel as Label).text = key.to_upper()
	if has_node("ValueLabel"):
		($ValueLabel as Label).text = value_text
	queue_redraw()

func _draw() -> void:
	# Dashed line hugging the bottom edge of the row.
	var y := size.y - 1.0
	var x := 0.0
	const DASH := 2.0
	const STEP := 6.0
	while x < size.x:
		draw_line(Vector2(x, y), Vector2(minf(x + DASH, size.x), y), line_color, 1.0)
		x += STEP
