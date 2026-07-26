class_name Bed
extends Interactable

@export var bed_sound: AudioStream

func _ready() -> void:
	prompt_text = "Go To Bed"
	task_id ="sleep"
	add_to_group("tasks_objects")

func interact(player: Node) -> void:
	super.interact(player)
	print("Spím – koniec dňa")
	
	var duration = bed_sound.get_length()
	var fadeRect = get_tree().get_first_node_in_group("screen_fader") as ColorRect
	var tween = create_tween()
	tween.tween_property(fadeRect, "color:a", 1.0, duration)
	AudioManager.play_sound_3d(bed_sound, global_position, AudioManager.BUS_SFX, 0.0, 1.0, 0.03)
	await get_tree().create_timer(duration).timeout
	GameState.end_day()
	get_tree().change_scene_to_file("res://Main.tscn")
