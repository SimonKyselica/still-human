class_name SimpleTask
extends Interactable

@export var say_lines: Array[String] = []
@export var say_sfx: AudioStream
@export var say_pos: Vector2 = Vector2(960, 900)

func _ready() -> void:
	add_to_group("tasks_objects")
	
func interact(player: Node) -> void:
	super.interact(player)
	if not say_lines.is_empty():
		DialogueManager.start_dialog(say_pos, say_lines, say_sfx)
	GameState.complete_task(task_id)
