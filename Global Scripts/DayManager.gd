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
	# Defer: DayManager sits above the interactables in the scene tree, so its
	# _ready() runs before theirs. Calling the sync directly would look up the
	# "tasks_objects" group before the phone/bed/etc. have added themselves to
	# it (they do so in their own _ready()), finding an empty group and never
	# firing on_became_active(). call_deferred waits until all _ready()s finish.
	_sync_to_current_task.call_deferred()

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
	
const TASK_ACTIVATION_DELAY := 5.0  # seconds before a newly-active task turns on

func _sync_to_current_task() -> void:
	var active := GameState.current_task_id()
	for obj in get_tree().get_nodes_in_group("tasks_objects"):
		if obj is Interactable:
			var it: Interactable = obj
			var is_active := it.handles_task(active)
			it.enabled = false
			if is_active:
				# Delay the whole task (ring + interaction) by a few seconds.
				_activate_after(it, TASK_ACTIVATION_DELAY)
	_rebuild_ui()
	print("[DayManager] aktívna úloha = ", active, "  fáza = ", GameState.current_phase())


## Waits, then activates the task object — but only if it is still the active
## task (guards against the task advancing or the scene reloading mid-wait).
func _activate_after(it: Interactable, seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	if not is_instance_valid(it) or not it.handles_task(GameState.current_task_id()):
		return
	it.on_became_active()
	it.enabled = true
	
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
	# Font a veľkosť písma prichádzajú z projektového themu
	# (gui/theme/custom → UI/game_theme.tres), aby sa dali škálovať na jednom
	# mieste. Tu nastavujeme len text a farbu podľa stavu úlohy.
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
