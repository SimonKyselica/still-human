class_name Interactable
extends StaticBody3D

@export var prompt_text: String = "Interact"
@export var enabled: bool = true
@export var task_id: String = ""
@export var extra_task_ids: Array[String] = []

signal interacted(player: Node)

func handles_task(id: String) -> bool:
	return id != "" and (id == task_id or extra_task_ids.has(id))

func can_interact() -> bool:
	if not enabled:
		return false
	var bound := task_id != "" or not extra_task_ids.is_empty()
	if bound and not handles_task(GameState.current_task_id()):
		return false
	return true


## Override to change the prompt dynamically based on state.
func get_prompt_text() -> String:
	return prompt_text

func interact(player: Node) -> void:
	interacted.emit(player)
	
func on_became_active() -> void:
	pass
