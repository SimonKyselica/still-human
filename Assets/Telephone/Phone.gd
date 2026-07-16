## Example: the door from the end of Path A ("Prebudenie"). Starts disabled
## since the door doesn't exist in the room until Day 3.
class_name Telephone
extends Interactable

@export var target_scene: String = ""

func _ready() -> void:
	prompt_text = "Pick up Telephone"
	enabled = true

func interact(player: Node) -> void:
	super.interact(player)
	print("Interacted with Telephone")
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
