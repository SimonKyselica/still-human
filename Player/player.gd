extends CharacterBody3D

# --- Movement Variables ---
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

# --- Node References ---
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

# Get the gravity from the project settings to sync with physics
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Capture the mouse cursor so it doesn't wander off the screen initially
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# --- THE ESCAPE HATCH ---
	# "ui_cancel" is Godot's default action for the Escape key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Handle mouse movement for looking around (ONLY if the mouse is captured)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		# Rotate the player body left and right (Y axis)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Rotate the head up and down (X axis)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		
		# Clamp the head rotation so you can't flip your neck upside down
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
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
