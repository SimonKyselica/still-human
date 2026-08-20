extends CharacterBody3D

# --- Movement Variables ---
const SPEED = 3.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

# --- Node References ---
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interaction_component: InteractionComponent = $Head/Camera3D/InteractionComponent
@onready var shader_overlay = $Head/Camera3D/Shader_Overlay

# Get the gravity from the project settings to sync with physics
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const STEP_DISTANCE := 2.0   # metres between footsteps — tune to taste
var _step_accum := 0.0
var _footsteps: Array[AudioStream] = [
	preload("res://sfx/walking_1.wav"),
	preload("res://sfx/walking_2.wav"),
	preload("res://sfx/walking_3.wav"),
]

## Whether the player *should* have mouse look right now. Deliberately kept
## separate from the OS mouse mode: the OS can refuse or silently drop capture
## (window not focused yet at startup, alt-tab, platform quirks), and reading
## that state back as the source of truth is how you end up with a game that
## never looks around again and gives the player no way to find out why.
var _mouse_look: bool = true

## Scripted poses — sitting on the couch, and anything like it — take the
## controls away in two separate pieces on purpose. The pose tween owns the body
## while it plays, but once you have settled you can still look around the room.
## Freezing the camera too is what makes a scripted sit read as a cutscene
## instead of somewhere you chose to be.
var _movement_locked: bool = false
var _look_locked: bool = false

## Optional yaw cone for those poses: on the couch you can turn your head, you
## can't swivel round to face the backrest. Negative half-range means no limit.
var _yaw_center: float = 0.0
var _yaw_limit: float = -1.0


func _ready() -> void:
	# Capture the mouse cursor so it doesn't wander off the screen initially
	_set_mouse_look(true)


func _notification(what: int) -> void:
	# Capture can fail if it is requested before the window has focus — exactly
	# the sort of thing that happens on one machine and not another. Re-apply it
	# every time the window comes back.
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and _mouse_look:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _set_mouse_look(on: bool) -> void:
	_mouse_look = on
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if on else Input.MOUSE_MODE_VISIBLE)


# ---------------------------------------------------------------------------
# SCRIPTED POSE API — called by interactables that pose the player (Couch)
# ---------------------------------------------------------------------------

## Stops walking. Whoever locks movement is expected to drive global_position
## itself, usually with a tween, which is why gravity and move_and_slide stop
## too — left running they fight the tween for the transform every frame.
func set_movement_locked(locked: bool) -> void:
	_movement_locked = locked
	interaction_component.set_targeting_enabled(not locked)
	if locked:
		velocity = Vector3.ZERO
		# So the first step after standing back up fires immediately.
		_step_accum = STEP_DISTANCE


func set_look_locked(locked: bool) -> void:
	_look_locked = locked


## Restricts mouse-look yaw to center_yaw ± half_range_rad (radians).
func set_yaw_limit(center_yaw: float, half_range_rad: float) -> void:
	_yaw_center = center_yaw
	_yaw_limit = half_range_rad
	_apply_yaw_limit()


func clear_yaw_limit() -> void:
	_yaw_limit = -1.0


func _apply_yaw_limit() -> void:
	if _yaw_limit < 0.0:
		return
	# wrapf first: rotation.y accumulates, so the raw difference between two yaws
	# is happily several turns wide and clamping that directly snaps the view.
	var offset := wrapf(rotation.y - _yaw_center, -PI, PI)
	rotation.y = _yaw_center + clampf(offset, -_yaw_limit, _yaw_limit)


func _unhandled_input(event: InputEvent) -> void:
	# --- THE ESCAPE HATCH ---
	# "ui_cancel" is Godot's default action for the Escape key

	# Click in the world to take the mouse back. Standard FPS behaviour, and the
	# one recovery a player finds without being told — it covers Escape hit by
	# accident and capture that never applied in the first place.
	if event is InputEventMouseButton and event.pressed and not _mouse_look:
		_set_mouse_look(true)
		return

	# Movement locked means posed: the interactable holding the pose owns the
	# interact key until it lets go (that's how you get off the couch).
	if event.is_action_pressed("interact") and not DialogueManager.is_dialogue_active \
			and not _movement_locked:
		interaction_component.try_interact(self)

	if event.is_action_pressed("ui_cancel"):
		_set_mouse_look(not _mouse_look)
	if event.is_action_pressed("debug"):
		shader_overlay.visible = !shader_overlay.visible

	# Handle mouse movement for looking around (ONLY if the mouse is captured)
	if _mouse_look and not _look_locked and event is InputEventMouseMotion:
		# Rotate the player body left and right (Y axis)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_apply_yaw_limit()

		# Rotate the head up and down (X axis)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)

		# Clamp the head rotation so you can't flip your neck upside down
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))



func _physics_process(delta: float) -> void:
	# Posed: the interactable that locked us is tweening the transform. Adding
	# gravity and move_and_slide on top would drag the player off the seat.
	if _movement_locked:
		return

	# 1. Add Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Handle Jump
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# 3. Get Input Vector (2D direction)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# 4. Calculate 3D Direction relative to where the player is looking
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# 5. Apply Movement (with smooth stopping)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# 6. Execute Godot's built-in physics movement
	move_and_slide()
	
	# Footsteps: accumulate horizontal ground distance, play a step each interval.
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and horizontal_speed > 0.1:
		_step_accum += horizontal_speed * delta
		if _step_accum >= STEP_DISTANCE:
			_step_accum = 0.0
			AudioManager.play_sound(_footsteps.pick_random(), AudioManager.BUS_SFX, -6.0)
	else:
		_step_accum = STEP_DISTANCE   # so the first step after stopping fires immediately
