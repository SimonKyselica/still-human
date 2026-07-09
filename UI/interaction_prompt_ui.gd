extends Label

func _ready() -> void:
	visible = false

func _on_target_changed(interactable: Interactable) -> void:
	if interactable:
		text = interactable.get_prompt_text()
		visible = true
	else:
		visible = false
