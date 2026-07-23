class_name PC
extends Interactable

@export var target_scene: String = "Audit/AuditTerminal.tscn"

func _ready() -> void:
	prompt_text = "Start Work"
	task_id = "terminal"
	add_to_group("tasks_objects")
	enabled = false

func interact(player: Node) -> void:
	super.interact(player)
	GameState.last_player_pos = "PC"
	
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
