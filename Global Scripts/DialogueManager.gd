extends Node

@onready var text_box_scene = preload("res://Assets/Dialogues/Text_box.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_pos: Vector2

var sfx: AudioStream

var is_dialogue_active = false
var can_advance_line = false

## Emitted once the last line has been dismissed and the conversation is over.
signal dialogue_finished

func start_dialog(position: Vector2, lines: Array[String], speech_sfx: AudioStream):
	if is_dialogue_active:
		return

	dialog_lines = lines
	text_box_pos = position
	sfx = speech_sfx
	show_text_box()
	
	is_dialogue_active = true
	
func show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_pos
	text_box.display_text(dialog_lines[current_line_index], sfx)
	can_advance_line = false
	
func on_text_box_finished_displaying():
	can_advance_line = true
	
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("advance_dialog") && is_dialogue_active && can_advance_line):
		text_box.queue_free()
		
		current_line_index +=1
		if current_line_index >= dialog_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			dialogue_finished.emit()
			return
			
		show_text_box()
