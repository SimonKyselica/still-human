class_name Interactable
extends StaticBody3D

## Shown in the UI prompt, e.g. "Press E to Answer"
@export var prompt_text: String = "Interact"

## Toggle off to temporarily disable interaction (locked door, used-up prop...)
@export var enabled: bool = true


signal interacted(player: Node)


## Override in subclasses for extra conditions (e.g. "only during Day 2").
func can_interact() -> bool:
	return enabled


## Override to change the prompt dynamically based on state.
func get_prompt_text() -> String:
	return prompt_text



func interact(player: Node) -> void:
	interacted.emit(player)
