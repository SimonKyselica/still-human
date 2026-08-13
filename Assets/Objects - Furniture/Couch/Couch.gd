class_name PC
extends Interactable

var sitting: bool = false

func _ready() -> void:
	prompt_text = "Sit on a couch"

func interact(player: Node) -> void:
	if sitting == false:
		super.interact(player)
		print("Sitting on a couch")
		sitting = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && sitting:
		sitting = false
		print("Standed from the couch")
		
