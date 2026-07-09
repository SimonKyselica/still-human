## Example: the door from the end of Path A ("Prebudenie"). Starts disabled
## since the door doesn't exist in the room until Day 3.
class_name Bed
extends Interactable

@export var target_scene: String = ""

func _ready() -> void:
	prompt_text = "Go To Bed"
	enabled = true

func interact(player: Node) -> void:
	super.interact(player)
	print("Interacted with bed")
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
