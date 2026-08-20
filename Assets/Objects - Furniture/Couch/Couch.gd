class_name Couch
extends Interactable

## Sit-down interaction. Interacting glides the player onto the seat, settles
## them facing out into the room, and fades calm nature ambience in. Pressing
## "interact" again gets them up and puts them back exactly where they were
## standing — a spot they already occupied, so standing up can never drop them
## inside the furniture.

## Where the player's body ends up, and which way they face: the marker's -Z is
## the facing direction, the same convention Godot uses everywhere else. Aim it
## in the editor by pointing the blue arrow away from the backrest.
@export var sit_point: Node3D

## Ambience for the sitting. Needs loop=true in its import settings, otherwise
## it plays through once and the couch goes quiet while you're still on it.
@export var calm_music: AudioStream
@export var music_volume_db: float = -6.0
@export var music_fade_in: float = 2.5
@export var music_fade_out: float = 1.5

@export var sit_sound: AudioStream
@export var stand_sound: AudioStream

## How long the glide onto and off the couch takes. Long enough to read as
## deliberate, short enough that it doesn't feel like it took the game away.
@export var move_duration: float = 0.9

## How far you can turn while seated. Looking around the room is the point of
## sitting down; swivelling round to face the backrest is not.
@export_range(0.0, 180.0) var seated_yaw_range_deg: float = 80.0

var sitting: bool = false

## True while a sit or stand tween is playing. This also guards a same-frame
## double fire: the keypress that seats you carries on to this node's own
## _unhandled_input, and without the guard you'd stand straight back up.
var _busy: bool = false

var _player: CharacterBody3D = null
var _stand_position: Vector3
var _stand_yaw: float = 0.0
var _tween: Tween


func _ready() -> void:
	prompt_text = "Sit on a couch"


## No prompt while seated or mid-transition — otherwise glancing down at the
## cushions offers you a couch you are already sitting on.
func can_interact() -> bool:
	if sitting or _busy:
		return false
	return super.can_interact()


func interact(player: Node) -> void:
	if sitting or _busy:
		return
	var body := player as CharacterBody3D
	if body == null:
		push_warning("Couch: interacting node is not a CharacterBody3D, ignoring.")
		return
	super.interact(player)
	_sit_down(body)


func _unhandled_input(event: InputEvent) -> void:
	if not sitting or _busy:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_stand_up()


func _sit_down(player: CharacterBody3D) -> void:
	_player = player
	_stand_position = player.global_position
	_stand_yaw = player.rotation.y

	sitting = true
	_busy = true
	player.set_movement_locked(true)
	player.set_look_locked(true)   # the pose tween owns the camera until it lands

	if sit_sound != null:
		AudioManager.play_sound_3d(sit_sound, global_position, AudioManager.BUS_SFX, -4.0, 1.0, 0.03)

	# Ambience starts with the move rather than after it: by the time the player
	# has settled it is most of the way faded in, which is what makes it read as
	# the room going calm instead of a track being switched on.
	if calm_music != null:
		AudioManager.play_music(calm_music, music_fade_in, music_volume_db)

	var seat := _seat_transform()
	_move_player_to(seat.origin, seat.basis.get_euler().y, true)
	await _tween.finished

	_busy = false
	player.set_look_locked(false)
	player.set_yaw_limit(player.rotation.y, deg_to_rad(seated_yaw_range_deg))


func _stand_up() -> void:
	if _player == null:
		return
	var player := _player
	_busy = true
	player.clear_yaw_limit()
	player.set_look_locked(true)

	if stand_sound != null:
		AudioManager.play_sound_3d(stand_sound, global_position, AudioManager.BUS_SFX, -4.0, 1.0, 0.03)
	if calm_music != null:
		AudioManager.stop_music(music_fade_out)

	_move_player_to(_stand_position, _stand_yaw, false)
	await _tween.finished

	sitting = false
	_busy = false
	_player = null
	player.set_look_locked(false)
	player.set_movement_locked(false)


## The marker is authoritative. Without one the couch still works rather than
## erroring, it just seats you on its own origin — which is visible enough in
## game to send you back to the editor to place the marker.
func _seat_transform() -> Transform3D:
	if sit_point != null:
		return sit_point.global_transform
	push_warning("Couch: no sit_point assigned, seating the player on the couch origin.")
	return global_transform


func _move_player_to(target_position: Vector3, target_yaw: float, level_head: bool) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_player, "global_position", target_position, move_duration)

	# Shortest way round. rotation.y accumulates as the player turns, so tweening
	# to a raw target angle takes the scenic route — occasionally several full
	# turns of it — any time the two values straddle ±PI.
	var yaw := _player.rotation.y + wrapf(target_yaw - _player.rotation.y, -PI, PI)
	_tween.tween_property(_player, "rotation:y", yaw, move_duration)

	# Sitting down levels your gaze; standing up leaves it where you left it.
	if level_head:
		_tween.tween_property(_player.head, "rotation:x", 0.0, move_duration)


func _exit_tree() -> void:
	# End of day, or any other scene change, while the player is still sat down.
	# The ambience lives on the AudioManager autoload and would otherwise follow
	# them into the next scene, and the movement lock would follow them with it.
	if not sitting:
		return
	if calm_music != null:
		AudioManager.stop_music(0.5)
	if _player != null and is_instance_valid(_player):
		_player.clear_yaw_limit()
		_player.set_look_locked(false)
		_player.set_movement_locked(false)
