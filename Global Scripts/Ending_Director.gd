class_name EndingDirector
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameState.pending_ending == "DEATH":
		_play_death.call_deferred()
	elif GameState.day > 5:
		match GameState.resolve_ending():
			"GOOD": _play_good.call_deferred()
			"BAD":  _play_bad.call_deferred()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _play_death() -> void:
	pass
	
func _play_good() -> void:
	pass

func _play_bad() -> void:
	pass
