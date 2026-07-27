class_name Telephone
extends Interactable


@export var conver_pos: Vector2 = Vector2(980, 920)
var is_ringing: bool = true

@onready var speech_sound = preload("res://Assets/Sounds/Phone.wav")
@export var ring_player: AudioStreamPlayer3D
@export var pick_up_sound: AudioStream
@export var put_down_sound: AudioStream

const lines1: Array[String] = [
	"Welcome to your new job!",
	"We only expect the best of you!",
	"See you soon, Happy to have you onboard!"
]

const PRAISE_LINES: Array[String] = [
	"Clean shift. Every call matched the directive.",
	"Good. Keep it that way.",
]
const REPROACH_LINES: Array[String] = [
	"We reviewed your shift. You got calls wrong.",
	"Sloppy work is noticed. Don't make it a habit.",
]

func _ready() -> void:
	prompt_text = "Pick up Telephone"
	task_id = "phone"
	add_to_group("tasks_objects")
	is_ringing = true
	
func on_became_active() -> void:
	start_ringing()
	
func start_ringing() -> void:
	#await get_tree().create_timer(5).timeout
	is_ringing = true
	enabled = true
	print("Yo Phone Lingin")
	if ring_player and not ring_player.playing:
		ring_player.play()
	AudioManager.play_sound_3d(pick_up_sound, global_position, AudioManager.BUS_SFX, 0.0, 1.0, 0.03)
	#var duration = pick_up_sound.get_length()
	#await get_tree().create_timer(duration).timeout

func stop_ringing() -> void:
	is_ringing = false
	ring_player.stop()
	

func interact(player: Node) -> void:
	super.interact(player)
	stop_ringing()
	DialogueManager.start_dialog(conver_pos, _handler_lines(), speech_sound)
	GameState.complete_task("phone")   # zdvihnutie = dokončenie úlohy
	await DialogueManager.dialogue_finished
	# Hang up: play the put-down sound and wait out its length.
	AudioManager.play_sound_3d(put_down_sound, global_position, AudioManager.BUS_SFX, 0.0, 1.0, 0.03)
	await get_tree().create_timer(put_down_sound.get_length()).timeout
	
func _handler_lines() -> Array[String]:
	return PRAISE_LINES if GameState.shift_was_clean() else REPROACH_LINES
