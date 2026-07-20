class_name Telephone
extends Interactable


@export var conver_pos: Vector2 = Vector2(980, 920)
var is_ringing: bool = true

@onready var speech_sound = preload("res://Assets/Sounds/Phone.wav")
# @onready var ring_player: AudioStreamPlayer3D = $RingSound 

const lines1: Array[String] = [
	"Welcome to your new job!",
	"We only expect the best of you!",
	"See you soon, Happy to have you onboard!"
]

func _ready() -> void:
	prompt_text = "Pick up Telephone"
	task_id = "phone"
	add_to_group("task_objects")
	is_ringing = true
	
func on_became_active() -> void:
	start_ringing()
	
func start_ringing() -> void:
	is_ringing = true
	enabled = true
	print("Yo Phone Lingin")
	#ring_player.play()

func stop_ringing() -> void:
	is_ringing = false

func interact(player: Node) -> void:
	super.interact(player)
	stop_ringing()
	DialogueManager.start_dialog(conver_pos, lines1, speech_sound)
	GameState.complete_task("phone")   # zdvihnutie = dokončenie úlohy
