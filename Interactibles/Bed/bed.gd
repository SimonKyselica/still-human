class_name Bed
extends Interactable


func _ready() -> void:
	prompt_text = "Go To Bed"
	task_id ="sleep"
	add_to_group("tasks_objects")

func interact(player: Node) -> void:
	super.interact(player)
	print("Spím – koniec dňa")
	GameState.end_day()
	get_tree().change_scene_to_file("res://Main.tscn")
