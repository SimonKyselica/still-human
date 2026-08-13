extends MeshInstance3D

## The surveillance camera's head: pans to follow whoever is in the room, and
## blinks its recording LED.
##
## Sits on Cube_001 inside camera.glb. The OmniLight3D is a child of this node,
## so the LED swings with the head without any extra work.

# --- Tracking ---------------------------------------------------------------

@export var tracking_enabled: bool = true

## What to watch. Left empty it follows the active 3D camera — which in a
## first-person game is the player's eyes. No NodePath to wire, no group to
## join, and it keeps working if the player scene is ever re-instanced.
@export var target: Node3D

## Higher is snappier. Exponential approach, so it behaves the same at any
## framerate: 2–3 reads as a bored institutional sweep, 8+ looks alert.
@export_range(0.1, 20.0) var track_speed: float = 2.5

## Pan only, never tilt. Worth turning on if the head looks wrong when the
## player stands close underneath it.
@export var yaw_only: bool = false

## The model's own idea of "forward". Godot aims a node's -Z at its target, so
## if the housing points its back or its side at the player, this is the single
## number that fixes it — try 180 first, then ±90.
@export_range(-180.0, 180.0) var model_yaw_offset: float = 0.0
@export_range(-90.0, 90.0) var model_pitch_offset: float = 0.0

# --- Recording LED ----------------------------------------------------------

## Left empty it finds the OmniLight3D child by itself.
@export var led: Light3D

@export var led_energy: float = 4.0
@export var led_on_time: float = 0.12
@export var led_off_time: float = 1.4

## Below this the direction is too close to straight up or down for looking_at
## to resolve, so the head holds its last angle for a frame instead of erroring.
const GIMBAL_EPSILON := 0.999


func _ready() -> void:
	if led == null:
		led = get_node_or_null("OmniLight3D") as Light3D
	_start_led_blink()


func _process(delta: float) -> void:
	if not tracking_enabled:
		return
	var watched := _watched_node()
	if watched == null:
		return
	_aim_at(watched.global_position, delta)


func _watched_node() -> Node3D:
	if target != null and target.is_inside_tree():
		return target
	return get_viewport().get_camera_3d()


func _aim_at(global_point: Vector3, delta: float) -> void:
	var parent := get_parent_node_3d()
	if parent == null:
		return

	# Everything happens in the parent's space on purpose. The whole camera rig
	# is scaled 1.3 and turned 180° on Y in Main.tscn; doing the maths locally
	# keeps both out of it. And assigning `quaternion` rather than `basis` is
	# what stops the head from losing its inherited scale.
	var inv := parent.global_transform.affine_inverse()
	var local_point := inv * global_point
	var local_up := (inv.basis * Vector3.UP).normalized()

	var dir := local_point - position
	if yaw_only:
		dir -= local_up * dir.dot(local_up)
	if dir.length_squared() < 0.0001:
		return
	dir = dir.normalized()
	if absf(dir.dot(local_up)) > GIMBAL_EPSILON:
		return   # player is directly overhead/underneath — hold the last angle

	var aim := Basis.looking_at(dir, local_up)
	if model_yaw_offset != 0.0 or model_pitch_offset != 0.0:
		# Post-multiplied, so the correction turns the housing about its own
		# axes after it has been aimed.
		aim *= Basis.from_euler(Vector3(
			deg_to_rad(model_pitch_offset), deg_to_rad(model_yaw_offset), 0.0))

	# Exponential smoothing: framerate-independent and it never overshoots.
	var weight := 1.0 - exp(-track_speed * delta)
	quaternion = quaternion.slerp(aim.get_rotation_quaternion(), weight)


## One looping tween rather than a counter in _process: declarative, and it
## costs nothing per frame. A sharp on-pulse and a long dark gap reads as a
## recording indicator; an even fade reads as decoration.
func _start_led_blink() -> void:
	if led == null:
		push_warning("Camera: no LED assigned and no OmniLight3D child found.")
		return
	led.light_energy = 0.0
	var t := led.create_tween().set_loops()
	t.tween_property(led, "light_energy", led_energy, 0.06)
	t.tween_interval(led_on_time)
	t.tween_property(led, "light_energy", 0.0, 0.10)
	t.tween_interval(led_off_time)
