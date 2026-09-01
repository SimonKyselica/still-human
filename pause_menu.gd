extends Control

@onready var main = $"../"


func _on_resume_pressed() -> void:
	main.pauseMenu()


func _on_exit_pressed() -> void:
	get_tree().quit()
