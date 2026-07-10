
class_name PC
extends Interactable

@export var target_scene: String = "Audit/AuditTerminal.tscn"

func _ready() -> void:
	prompt_text = "Start Work"
	enabled = true

func interact(player: Node) -> void:
	super.interact(player)
	print("Started Working")
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
