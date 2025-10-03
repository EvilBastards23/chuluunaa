extends Node3D
class_name PresentationControls

# Interactive controls for presentation navigation
# Handles buttons, levers, and other interactive elements

signal next_slide_requested
signal previous_slide_requested
signal presentation_start_requested
signal presentation_stop_requested

@export var control_type: ControlType = ControlType.BUTTON
@export var control_label: String = "Next Slide"
@export var interaction_distance: float = 3.0
@export var highlight_color: Color = Color.CYAN
@export var active_color: Color = Color.GREEN
@export var disabled_color: Color = Color.GRAY

enum ControlType {
	BUTTON,
	LEVER,
	PEDESTAL,
	TOGGLE
}

var is_interactable: bool = true
var is_highlighted: bool = false
var is_active: bool = false
var nearby_player: Node3D = null

# Visual components
@onready var control_mesh: MeshInstance3D
@onready var highlight_material: StandardMaterial3D
@onready var interaction_area: Area3D
@onready var label_3d: Label3D

# Animation
var original_scale: Vector3
var animation_tween: Tween

func _ready():
	setup_control()
	setup_interaction_area()
	setup_visual_feedback()
	original_scale = scale

func setup_control():
	"""Setup the control based on its type"""
	# No visual mesh needed - just interaction area
	setup_invisible_control()

func setup_button():
	"""Setup a button control"""
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.3
	cylinder_mesh.bottom_radius = 0.3
	cylinder_mesh.height = 0.2
	
	control_mesh = MeshInstance3D.new()
	control_mesh.mesh = cylinder_mesh
	control_mesh.name = "ButtonMesh"
	add_child(control_mesh)

func setup_lever():
	"""Setup a lever control"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.1, 0.8, 0.1)
	
	control_mesh = MeshInstance3D.new()
	control_mesh.mesh = box_mesh
	control_mesh.name = "LeverMesh"
	add_child(control_mesh)
	
	# Add a base for the lever
	var base_mesh = CylinderMesh.new()
	base_mesh.top_radius = 0.2
	base_mesh.bottom_radius = 0.2
	base_mesh.height = 0.1
	
	var base_instance = MeshInstance3D.new()
	base_instance.mesh = base_mesh
	base_instance.position = Vector3(0, -0.45, 0)
	base_instance.name = "LeverBase"
	add_child(base_instance)

func setup_pedestal():
	"""Setup a pedestal control"""
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.4
	cylinder_mesh.bottom_radius = 0.5
	cylinder_mesh.height = 1.2
	
	control_mesh = MeshInstance3D.new()
	control_mesh.mesh = cylinder_mesh
	control_mesh.name = "PedestalMesh"
	add_child(control_mesh)
	
	# Add a top platform
	var platform_mesh = CylinderMesh.new()
	platform_mesh.top_radius = 0.45
	platform_mesh.bottom_radius = 0.45
	platform_mesh.height = 0.1
	
	var platform_instance = MeshInstance3D.new()
	platform_instance.mesh = platform_mesh
	platform_instance.position = Vector3(0, 0.65, 0)
	platform_instance.name = "Platform"
	add_child(platform_instance)

func setup_toggle():
	"""Setup a toggle switch control"""
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.3, 0.1, 0.6)
	
	control_mesh = MeshInstance3D.new()
	control_mesh.mesh = box_mesh
	control_mesh.name = "ToggleMesh"
	add_child(control_mesh)

func setup_interaction_area():
	"""Setup the area for player interaction"""
	interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = interaction_distance
	collision_shape.shape = sphere_shape
	interaction_area.add_child(collision_shape)
	
	# Connect signals
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	
	add_child(interaction_area)

func setup_invisible_control():
	"""Setup an invisible control with just interaction area"""
	# No visual mesh needed - just the interaction area
	pass

func setup_visual_feedback():
	"""Setup visual feedback materials and labels"""
	# Create 3D label for interaction hint
	label_3d = Label3D.new()
	label_3d.text = control_label
	label_3d.font_size = 24
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.position = Vector3(0, 1.5, 0)
	label_3d.modulate = Color.WHITE
	add_child(label_3d)
	
	update_visual_state()

func _on_player_entered(body):
	if body.is_in_group("players") and is_interactable:
		nearby_player = body
		set_highlighted(true)

func _on_player_exited(body):
	if body == nearby_player:
		nearby_player = null
		set_highlighted(false)

func set_highlighted(value: bool):
	"""Set the highlighted state"""
	if is_highlighted == value:
		return
	
	is_highlighted = value
	update_visual_state()
	
	if value:
		animate_highlight()
	else:
		animate_normal()

func set_active(value: bool):
	"""Set the active state"""
	if is_active == value:
		return
	
	is_active = value
	update_visual_state()
	
	if value:
		animate_activation()
	else:
		animate_deactivation()

func update_visual_state():
	"""Update the visual appearance based on state"""
	# Update label color instead of material
	if not label_3d:
		return
	
	var target_color: Color
	
	if not is_interactable:
		target_color = disabled_color
	elif is_active:
		target_color = active_color
	elif is_highlighted:
		target_color = highlight_color
	else:
		target_color = Color.WHITE
	
	label_3d.modulate = target_color

func animate_highlight():
	"""Animate when highlighted"""
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween()
	animation_tween.set_loops()
	animation_tween.tween_property(self, "scale", original_scale * 1.1, 0.5)
	animation_tween.tween_property(self, "scale", original_scale, 0.5)

func animate_normal():
	"""Animate back to normal"""
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween()
	animation_tween.tween_property(self, "scale", original_scale, 0.3)

func animate_activation():
	"""Animate when activated"""
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween()
	animation_tween.tween_property(self, "scale", original_scale * 0.9, 0.1)
	animation_tween.tween_property(self, "scale", original_scale * 1.2, 0.2)
	animation_tween.tween_property(self, "scale", original_scale, 0.3)

func animate_deactivation():
	"""Animate when deactivated"""
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween()
	animation_tween.tween_property(self, "scale", original_scale, 0.3)

func interact(player: Node3D):
	"""Handle player interaction with the control"""
	if not is_interactable or not nearby_player:
		return false
	
	# Trigger the appropriate action based on control label
	match control_label.to_lower():
		"next slide", "next":
			next_slide_requested.emit()
		"previous slide", "previous", "back":
			previous_slide_requested.emit()
		"start presentation", "start":
			presentation_start_requested.emit()
		"stop presentation", "stop":
			presentation_stop_requested.emit()
		_:
			# Default to next slide
			next_slide_requested.emit()
	
	# Visual feedback
	set_active(true)
	await get_tree().create_timer(0.5).timeout
	set_active(false)
	
	print("Control activated: ", control_label)
	return true

func set_interactable(value: bool):
	"""Enable or disable interaction"""
	is_interactable = value
	update_visual_state()

func set_control_label(new_label: String):
	"""Change the control label"""
	control_label = new_label
	if label_3d:
		label_3d.text = new_label

func get_control_info() -> Dictionary:
	"""Get information about the control"""
	return {
		"type": ControlType.keys()[control_type],
		"label": control_label,
		"is_interactable": is_interactable,
		"is_highlighted": is_highlighted,
		"is_active": is_active,
		"nearby_player": nearby_player != null
	}
