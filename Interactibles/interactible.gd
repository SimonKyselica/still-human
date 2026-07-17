class_name Interactable
extends StaticBody3D

@export var prompt_text: String = "Interact"
@export var enabled: bool = true
@export var task_id: String = ""

signal interacted(player: Node)


func can_interact() -> bool:
	if not enabled:
		return false
	if task_id != "" and GameState.current_task_id() != task_id:
		return false
	return true


## Override to change the prompt dynamically based on state.
func get_prompt_text() -> String:
	return prompt_text

func interact(player: Node) -> void:
	interacted.emit(player)
	
func on_became_active() -> void:
	pass
