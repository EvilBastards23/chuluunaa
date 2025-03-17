extends CharacterBody3D

@export var walk_speed := 5.0
@export var sprint_speed := 10.0
@export var jump_force := 5.0
@export var gravity := 9.8
@export var mouse_sensitivity := 0.003

var velocity_dir := Vector3.ZERO
var camera_pitch := 0.0
@onready var camera = $Camera3D  # Reference the Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Hide & lock cursor

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)  # Rotate body
		camera_pitch -= event.relative.y * mouse_sensitivity  # Rotate camera up/down
		camera_pitch = clamp(camera_pitch, -1.2, 1.2)  # Prevent flipping
		camera.rotation.x = camera_pitch

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Sprinting logic
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	
	# Get movement direction
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"): input_dir.y -= 1
	if Input.is_action_pressed("move_backward"): input_dir.y += 1
	if Input.is_action_pressed("move_left"): input_dir.x -= 1
	if Input.is_action_pressed("move_right"): input_dir.x += 1

	# Convert input to 3D direction relative to the player
	input_dir = input_dir.normalized()
	velocity_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply movement
	velocity.x = velocity_dir.x * current_speed
	velocity.z = velocity_dir.z * current_speed

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
