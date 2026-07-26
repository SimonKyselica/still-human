class_name Lamp
extends Interactable

@export var turn_light_audio: AudioStream
@export var light: OmniLight3D

func _ready() -> void:
	prompt_text = "Turn the light"
	enabled = true
	

func interact(player: Node) -> void:
	super.interact(player)
	print("Lampa svieti")
	AudioManager.play_sound_3d(turn_light_audio, global_position, AudioManager.BUS_SFX, 0.0, 1.0, 0.04)
	if light:
		light.visible = !light.visible
