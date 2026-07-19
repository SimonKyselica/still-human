class_name DayManager
extends Node

@export var player_path: NodePath
var _player: Node3D
var _ui: VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player = get_node_or_null(player_path)
	_spawn_player()
	GameState.task_advanced.connect(_on_task_advanced)
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
	if n == null:
		push_warning("DayManager: chýba Marker3D 'Spawn_%s'" % anchor)
	return n as Node3D
	
func _sync_to_current_task() -> void:
	var active := GameState.current_task_id()
	for obj in get_tree().get_node_in_group("task_objects"):
		if obj is Interactable:
			var it: Interactable = obj
			var is_active := it.task_id == active
			it.enabled = is_active
			if is_active:
				it.on_became_active()
	_rebuild_ui()
	print("[DayManager] aktívna úloha = ", active, "  fáza = ", GameState.current_phase())
	
func _on_task_advanced(_new_task: DayTask) -> void:
	_sync_to_current_task()

func _on_phase_changed(new_phase: String) -> void:
	print("[DayManager] FÁZA -> ", new_phase)
	# TODO

func _rebuild_ui() -> void:
	if _ui == null:
		var layer := CanvasLayer.new()
		add_child(layer)
		_ui = VBoxContainer.new()
		_ui.position = Vector2(40, 40)
		layer.add_child(_ui)
	for c in _ui.get_children():
		c.queue_free()
	for i in GameState.schedule.size():
		var t: DayTask = GameState.schedule[i]
		var row := Label.new()
		if i < GameState.current_task_index:
			row.text = "✔ " + t.title
			row.modulate = Color(0.44, 0.44, 0.39)   # hotové – tlmené
		elif i == GameState.current_task_index:
			row.text = "▸ " + t.title
			row.modulate = Color(0.88, 0.64, 0.22)   # aktívne – jantár
		else:
			row.text = "• " + t.title
			row.modulate = Color(0.35, 0.35, 0.32)   # zamknuté – šedé
		_ui.add_child(row)
