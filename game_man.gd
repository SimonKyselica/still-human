extends Node3D

@onready var lights = $Lights

func _ready() -> void:
	var interaction_component = $Player/Head/Camera3D/InteractionComponent
	var prompt_label = $HUD/PromptLabel
	interaction_component.target_changed.connect(prompt_label._on_target_changed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		for light in get_tree().get_nodes_in_group("light"):
			light.visible = !light.visible
