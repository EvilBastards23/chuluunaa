extends RigidBody3D
class_name PresentationBook

# Interactive book that triggers day/night transition when placed correctly
# Can be picked up and moved by the player

signal book_picked_up
signal book_placed_correctly
signal book_dropped

@export var book_texture: Texture2D
@export var placement_area_size: Vector3 = Vector3(2.0, 0.5, 2.0)
@export var placement_tolerance: float = 0.3
@export var highlight_color: Color = Color.YELLOW
@export var correct_placement_color: Color = Color.GREEN

var is_being_carried: bool = false
var is_in_placement_area: bool = false
var is_correctly_placed: bool = false
var original_position: Vector3
var original_rotation: Vector3
var carrying_player: Node3D = null

# Placement area detection
@onready var placement_area: Area3D
@onready var placement_mesh: MeshInstance3D
@onready var book_mesh: MeshInstance3D
@onready var highlight_material: StandardMaterial3D

func _ready():
	setup_book()
	setup_placement_area()
	original_position = global_position
	original_rotation = global_rotation_degrees

func setup_book():
	"""Setup the book's visual and physics properties"""
	# Create book mesh (simple box for now)
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.3, 0.05, 0.4)  # Book proportions
	
	book_mesh = MeshInstance3D.new()
	book_mesh.mesh = box_mesh
	book_mesh.name = "BookMesh"
	
	# Apply book texture if available
	if book_texture:
		var material = StandardMaterial3D.new()
		material.albedo_texture = book_texture
		material.albedo_color = Color.WHITE
		book_mesh.material_override = material
	
	add_child(book_mesh)
	
	# Setup physics
	mass = 0.5
	gravity_scale = 1.0
	linear_damp = 2.0
	angular_damp = 5.0
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.3, 0.05, 0.4)
	collision_shape.shape = box_shape
	add_child(collision_shape)

func setup_placement_area():
	"""Setup the placement area where the book should be placed"""
	placement_area = Area3D.new()
	placement_area.name = "PlacementArea"
	
	# Create collision shape for placement area
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = placement_area_size
	collision_shape.shape = box_shape
	placement_area.add_child(collision_shape)
	
	# Create visual indicator for placement area
	var box_mesh = BoxMesh.new()
	box_mesh.size = placement_area_size
	
	placement_mesh = MeshInstance3D.new()
	placement_mesh.mesh = box_mesh
	placement_mesh.name = "PlacementMesh"
	
	# Create highlight material
	highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = highlight_color
	highlight_material.flags_transparent = true
	highlight_material.flags_unshaded = true
	highlight_material.albedo_color.a = 0.3
	placement_mesh.material_override = highlight_material
	
	placement_area.add_child(placement_mesh)
	
	# Connect signals
	placement_area.body_entered.connect(_on_placement_area_entered)
	placement_area.body_exited.connect(_on_placement_area_exited)
	
	# Add to scene (this will be positioned by the main scene)
	get_parent().add_child(placement_area)

func _physics_process(delta):
	if is_being_carried and carrying_player:
		# Follow the player's position with slight offset
		var target_position = carrying_player.global_position + carrying_player.transform.basis.z * -1.0 + Vector3.UP * 0.5
		var target_rotation = carrying_player.global_rotation
		
		# Smooth movement
		global_position = global_position.lerp(target_position, 10.0 * delta)
		global_rotation = global_rotation.lerp(target_rotation, 10.0 * delta)

func _on_placement_area_entered(body):
	if body == self:
		is_in_placement_area = true
		check_placement()
		update_placement_visual()

func _on_placement_area_exited(body):
	if body == self:
		is_in_placement_area = false
		is_correctly_placed = false
		update_placement_visual()

func check_placement():
	"""Check if the book is correctly placed"""
	if not is_in_placement_area:
		return
	
	# Check if book is roughly horizontal and in the right position
	var rotation_diff = abs(global_rotation_degrees.x) + abs(global_rotation_degrees.z)
	var position_diff = global_position.distance_to(placement_area.global_position)
	
	if rotation_diff < 30.0 and position_diff < placement_tolerance:
		if not is_correctly_placed:
			is_correctly_placed = true
			book_placed_correctly.emit()
			print("Book correctly placed! Triggering day/night transition...")
			update_placement_visual()
	else:
		if is_correctly_placed:
			is_correctly_placed = false
			update_placement_visual()

func update_placement_visual():
	"""Update the visual feedback for placement area"""
	if not placement_mesh or not highlight_material:
		return
	
	if is_correctly_placed:
		highlight_material.albedo_color = correct_placement_color
		highlight_material.albedo_color.a = 0.5
	elif is_in_placement_area:
		highlight_material.albedo_color = highlight_color
		highlight_material.albedo_color.a = 0.4
	else:
		highlight_material.albedo_color = highlight_color
		highlight_material.albedo_color.a = 0.2

func pickup_book(player: Node3D):
	"""Allow player to pick up the book"""
	if is_being_carried:
		return false
	
	is_being_carried = true
	carrying_player = player
	
	# Disable physics while being carried
	freeze = true
	gravity_scale = 0.0
	
	book_picked_up.emit()
	print("Book picked up by player")
	return true

func drop_book():
	"""Drop the book"""
	if not is_being_carried:
		return
	
	is_being_carried = false
	carrying_player = null
	
	# Re-enable physics
	freeze = false
	gravity_scale = 1.0
	
	# Check placement after a short delay
	await get_tree().create_timer(0.5).timeout
	check_placement()
	
	book_dropped.emit()
	print("Book dropped")

func reset_book():
	"""Reset the book to its original position"""
	drop_book()
	global_position = original_position
	global_rotation_degrees = original_rotation
	is_correctly_placed = false
	is_in_placement_area = false
	update_placement_visual()

func set_placement_area_position(position: Vector3, rotation: Vector3 = Vector3.ZERO):
	"""Set the position of the placement area"""
	if placement_area:
		placement_area.global_position = position
		placement_area.global_rotation_degrees = rotation

func get_book_info() -> Dictionary:
	"""Get information about the book's current state"""
	return {
		"is_carried": is_being_carried,
		"is_in_placement_area": is_in_placement_area,
		"is_correctly_placed": is_correctly_placed,
		"position": global_position,
		"carrying_player": carrying_player
	}
