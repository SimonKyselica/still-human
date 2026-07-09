extends Node3D

func _ready() -> void:
	var interaction_component = $Player/Head/Camera3D/InteractionComponent
	var prompt_label = $HUD/PromptLabel
	interaction_component.target_changed.connect(prompt_label._on_target_changed)
