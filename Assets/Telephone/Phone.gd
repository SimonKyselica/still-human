## Example: the door from the end of Path A ("Prebudenie"). Starts disabled
## since the door doesn't exist in the room until Day 3.
class_name Telephone
extends Interactable

@export var target_scene: String = ""
@export var conver_pos: Vector2 = Vector2(980, 920)
var is_ringing: bool = true

@onready var speech_sound = preload("res://Assets/Sounds/Phone.wav")

const lines1: Array[String] = [
	"Welcome to your new job!",
	"We only expect the best of you!"
]

func _ready() -> void:
	prompt_text = "Pick up Telephone"
	enabled = true
	
func _process(delta: float) -> void:
	if is_ringing == true:
		enabled = true

func interact(player: Node) -> void:
	super.interact(player)
	print("Interacted with Telephone")
	DialogueManager.start_dialog(conver_pos, lines1, speech_sound)
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
