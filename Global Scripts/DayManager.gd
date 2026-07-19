class_name DayManager
extends Node

@export var player_path: NodePath
var _player: Node3D
var _ui: VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player = get_node_or_null(player_path)
	_spawn_player()
	GameState.task_advanced.connect(on_task_advanced)
	GameState.phase_changed.connect(_on_phase_changed)
	_sync_to_current_task()

func _spawn_player() -> void:
	if _player == null:
		return
	var marker := _find_spawn(GameState.last_player_pos)
	if marker:
			_player.global_transform = marker.global_transform
func _find_spawn(anchor: String) -> Node3D:
	var n := get_tree().current_scene.find_child("Spawn_%s" % anchor, true, false)
