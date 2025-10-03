extends Node3D
class_name SeashellProjector

# Customizable seashell projector for presentation slides
# Acts as a physical projector with adjustable settings

signal projector_activated
signal projector_deactivated
signal slide_changed(slide_index: int)

@export var projection_width: float = 8.0
@export var projection_height: float = 6.0
@export var projection_distance: float = 15.0
@export var projection_angle: float = 0.0  # Degrees
@export var projection_intensity: float = 1.0
@export var projection_color: Color = Color.WHITE

@export var is_active: bool = false
@export var current_slide_index: int = 0

var slides: Array[Texture2D] = []
var projection_mesh: MeshInstance3D
var projection_material: ShaderMaterial
var seashell_mesh: MeshInstance3D
var seashell_material: StandardMaterial3D

# Animation
var animation_tween: Tween
var original_scale: Vector3

func _ready():
	setup_seashell()
	setup_projection()
	original_scale = scale

func setup_seashell():
	"""Setup the seashell visual"""
	# Create a simple seashell shape (you can replace this with your imported model)
	var shell_mesh = SphereMesh.new()
	shell_mesh.radius = 0.8
	shell_mesh.height = 1.2
	
	seashell_mesh = MeshInstance3D.new()
	seashell_mesh.mesh = shell_mesh
	seashell_mesh.name = "SeashellMesh"
	
	# Create seashell material
	seashell_material = StandardMaterial3D.new()
	seashell_material.albedo_color = Color(0.9, 0.8, 0.7)  # Shell color
	seashell_material.metallic = 0.1
	seashell_material.roughness = 0.8
	seashell_mesh.material_override = seashell_material
	
	add_child(seashell_mesh)
	
	# Add a subtle glow effect
	var glow_mesh = SphereMesh.new()
	glow_mesh.radius = 1.0
	glow_mesh.height = 1.4
	
	var glow_instance = MeshInstance3D.new()
	glow_instance.mesh = glow_mesh
	glow_instance.name = "GlowMesh"
	
	var glow_material = StandardMaterial3D.new()
	glow_material.albedo_color = Color(1.0, 0.9, 0.7, 0.3)
	glow_material.flags_transparent = true
	glow_material.flags_unshaded = true
	glow_instance.material_override = glow_material
	
	add_child(glow_instance)

func setup_projection():
	"""Setup the projection system"""
	# Create projection quad
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(projection_width, projection_height)
	
	projection_mesh = MeshInstance3D.new()
	projection_mesh.mesh = quad_mesh
	projection_mesh.name = "ProjectionMesh"
	
	# Create projection shader material
	var shader = preload("res://seashell_projection_shader.gdshader")
	projection_material = ShaderMaterial.new()
	projection_material.shader = shader
	
	projection_mesh.material_override = projection_material
	
	# Position the projection
	update_projection_position()
	
	# Initially hidden
	projection_mesh.visible = false
	
	add_child(projection_mesh)

func update_projection_position():
	"""Update projection position based on settings"""
	if not projection_mesh:
		return
	
	# Calculate projection position based on distance and angle
	var angle_rad = deg_to_rad(projection_angle)
	var forward = Vector3(sin(angle_rad), 0, cos(angle_rad))
	
	projection_mesh.position = forward * projection_distance
	projection_mesh.rotation_degrees = Vector3(0, projection_angle, 0)
	
	# Update projection size
	if projection_mesh.mesh:
		projection_mesh.mesh.size = Vector2(projection_width, projection_height)

func activate_projector():
	"""Activate the seashell projector"""
	if is_active:
		return
	
	is_active = true
	projection_mesh.visible = true
	
	# Animate activation
	animate_activation()
	
	projector_activated.emit()
	print("🐚 Seashell projector activated!")

func deactivate_projector():
	"""Deactivate the seashell projector"""
	if not is_active:
		return
	
	is_active = false
	
	# Animate deactivation
	animate_deactivation()
	
	projector_deactivated.emit()
	print("🐚 Seashell projector deactivated!")

func show_slide(index: int):
	"""Show a specific slide"""
	if index < 0 or index >= slides.size():
		return
	
	current_slide_index = index
	
	if slides[index]:
		projection_material.set_shader_parameter("slide_texture", slides[index])
		projection_material.set_shader_parameter("intensity", projection_intensity)
		projection_material.set_shader_parameter("projection_color", projection_color)
	
	slide_changed.emit(index)
	print("🐚 Showing slide ", index + 1, " of ", slides.size())

func hide_slide():
	"""Hide the current slide"""
	projection_mesh.visible = false

func add_slide(texture: Texture2D):
	"""Add a slide to the projector"""
	if texture:
		slides.append(texture)
		print("🐚 Added slide. Total: ", slides.size())

func remove_slide(index: int):
	"""Remove a slide"""
	if index >= 0 and index < slides.size():
		slides.remove_at(index)
		if current_slide_index >= slides.size():
			current_slide_index = max(0, slides.size() - 1)
		print("🐚 Removed slide. Total: ", slides.size())

func next_slide():
	"""Go to next slide"""
	if slides.is_empty():
		return
	
	current_slide_index = (current_slide_index + 1) % slides.size()
	show_slide(current_slide_index)

func previous_slide():
	"""Go to previous slide"""
	if slides.is_empty():
		return
	
	current_slide_index = (current_slide_index - 1 + slides.size()) % slides.size()
	show_slide(current_slide_index)

func animate_activation():
	"""Animate projector activation"""
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween()
	animation_tween.set_parallel(true)
	
	# Scale up the seashell
	animation_tween.tween_property(self, "scale", original_scale * 1.2, 0.5)
	
	# Fade in projection
	animation_tween.tween_method(
		func(alpha): projection_material.set_shader_parameter("alpha", alpha),
		0.0, 1.0, 0.8
	)
	
	# Scale back to normal
	animation_tween.tween_property(self, "scale", original_scale, 0.3).set_delay(0.5)

func animate_deactivation():
	"""Animate projector deactivation"""
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween()
	animation_tween.set_parallel(true)
	
	# Fade out projection
	animation_tween.tween_method(
		func(alpha): projection_material.set_shader_parameter("alpha", alpha),
		1.0, 0.0, 0.5
	)
	
	# Scale down
	animation_tween.tween_property(self, "scale", original_scale * 0.8, 0.5)
	
	animation_tween.finished.connect(func():
		projection_mesh.visible = false
		scale = original_scale
	)

# Customizable properties
func set_projection_width(width: float):
	"""Set projection width"""
	projection_width = width
	update_projection_position()

func set_projection_height(height: float):
	"""Set projection height"""
	projection_height = height
	update_projection_position()

func set_projection_distance(distance: float):
	"""Set projection distance"""
	projection_distance = distance
	update_projection_position()

func set_projection_angle(angle: float):
	"""Set projection angle in degrees"""
	projection_angle = angle
	update_projection_position()

func set_projection_intensity(intensity: float):
	"""Set projection intensity"""
	projection_intensity = intensity
	if projection_material:
		projection_material.set_shader_parameter("intensity", intensity)

func set_projection_color(color: Color):
	"""Set projection color tint"""
	projection_color = color
	if projection_material:
		projection_material.set_shader_parameter("projection_color", color)

func get_projector_info() -> Dictionary:
	"""Get projector information"""
	return {
		"is_active": is_active,
		"current_slide": current_slide_index,
		"total_slides": slides.size(),
		"projection_width": projection_width,
		"projection_height": projection_height,
		"projection_distance": projection_distance,
		"projection_angle": projection_angle,
		"projection_intensity": projection_intensity
	}
