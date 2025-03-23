extends CharacterBody3D

@export var walk_speed := 5.0
@export var sprint_speed := 10.0
@export var jump_force := 5.0
@export var gravity := 9.8
@export var mouse_sensitivity := 0.003

var velocity_dir := Vector3.ZERO
var camera_pitch := 0.0
@onready var camera = $Node3D/Camera3D
var interactable_door = null  # Store reference to the nearby door

func _ready():
	camera.current = is_multiplayer_authority()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Hide & lock cursor

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)  # Rotate body
		camera_pitch -= event.relative.y * mouse_sensitivity  # Rotate camera up/down
		camera_pitch = clamp(camera_pitch, -1.2, 1.2)  # Prevent flipping
		camera.rotation.x = camera_pitch

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"): input_dir.y -= 1
	if Input.is_action_pressed("move_backward"): input_dir.y += 1
	if Input.is_action_pressed("move_left"): input_dir.x -= 1
	if Input.is_action_pressed("move_right"): input_dir.x += 1

	input_dir = input_dir.normalized()
	velocity_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = velocity_dir.x * current_speed
	velocity.z = velocity_dir.z * current_speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	if Input.is_action_just_pressed("interact") and interactable_door:
		rpc("open_door")  # Call the open_door function on all clients

	move_and_slide()

func _on_area_entered(area):
	if area.is_in_group("doors"):
		interactable_door = area.get_parent()  
		print("Door detected!")

func _on_area_exited(area):
	if area.is_in_group("doors"):
		interactable_door = null
		print("Left door area!")

@rpc("call_local", "reliable")
func open_door():
	if interactable_door:
		interactable_door.rotation.y += 1.5  # Rotate the door
