class_name Telephone
extends Interactable


@export var conver_pos: Vector2 = Vector2(980, 920)
var is_ringing: bool = true

@onready var speech_sound = preload("res://Assets/Sounds/Phone.wav")
@export var ring_player: AudioStreamPlayer3D
@export var pick_up_sound: AudioStream
@export var put_down_sound: AudioStream


@export var animation_player: AnimationPlayer

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

const DAY1_MORNING: Array[String] = [
	"Morning. Welcome to your first shift.",
	"Clear anything under the threshold, hold the rest. Simple.",
	"We only expect the best of you.",
]
const DAY2_MORNING: Array[String] = [
	"Don't mind the smoke from the vent — it's a productivity measure.",
	"Today's rules overlap a little. Use your judgement.",
]
const DAY3_MORNING: Array[String] = [
	"Last shift. It's the hardest one. Be careful.",
]


func _ready() -> void:
	prompt_text = "Pick up Telephone"
	task_id = "phone"
	extra_task_ids = ["morning_phone"]
	add_to_group("tasks_objects")
	is_ringing = true
	
func on_became_active() -> void:
	start_ringing()
	
func start_ringing() -> void:
	#await get_tree().create_timer(5).timeout
	is_ringing = true
	enabled = true
	print("Yo Phone Lingin")
	animation_player.play("ringing")
	if ring_player and not ring_player.playing:
		ring_player.play()
	AudioManager.play_sound_3d(pick_up_sound, global_position, AudioManager.BUS_SFX, 0.0, 1.0, 0.03)
	#var duration = pick_up_sound.get_length()
	#await get_tree().create_timer(duration).timeout

func stop_ringing() -> void:
	is_ringing = false
	ring_player.stop()
	animation_player.stop()
	

func interact(player: Node) -> void:
	super.interact(player)
	stop_ringing()
	var task := GameState.current_task_id()
	DialogueManager.start_dialog(conver_pos, _handler_lines(task), speech_sound)
	GameState.complete_task(task)   # zdvihnutie = dokončenie úlohy
	await DialogueManager.dialogue_finished
	# Hang up: play the put-down sound and wait out its length.
	AudioManager.play_sound_3d(put_down_sound, global_position, AudioManager.BUS_SFX, 0.0, 1.0, 0.03)
	await get_tree().create_timer(put_down_sound.get_length()).timeout
	
func _handler_lines(task: String) -> Array[String]:
	if task == "morning_phone":
		return _morning_lines()
	return PRAISE_LINES if GameState.shift_was_clean() else REPROACH_LINES

func _morning_lines() -> Array[String]:
	if GameState.day == 2:
		return DAY2_MORNING
	elif GameState.day == 3:
		return DAY3_MORNING
	return DAY1_MORNING
	
	
		
	
	# Route A, day 3: "všimli sme si menšej chybičky v tvojom podaní"
# Route B, day 3: "chceme ťa pochváliť. Tvoj výkon nás veľmi oslnil."
# Same slot, same day, opposite worlds.

#func _morning_lines() -> Array[String]:
	# The CRITICAL warning outranks everything — it is the game's only
	# foreshadowing of the death ending, so it must not be crowded out.
	#if GameState.trust_band() == "CRITICAL":
		#return CRITICAL_WARNING[GameState.day]
	#if GameState.route() == "A":
		#return ROUTE_A_MORNING[GameState.day]   # suspicion, then threat
	#return ROUTE_B_MORNING[GameState.day]       # praise, then warmth
