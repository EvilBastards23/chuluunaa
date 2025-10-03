extends Node3D
class_name PresentationManager

# Presentation system for immersive slide shows in the game world
# Handles slide management, sky projection, and day/night transitions

signal slide_changed(slide_index: int)
signal presentation_started
signal presentation_ended
signal day_night_transition_started
signal day_night_transition_completed

@export var slides: Array[Texture2D] = []
@export var transition_duration: float = 20.0  # Long timelapse-style transition
@export var projection_size: Vector2 = Vector2(8.0, 6.0)
@export var projection_distance: float = 50.0
@export var projection_height: float = 20.0

var current_slide_index: int = 0
var is_presentation_active: bool = false
var is_transitioning: bool = false

# Sky projection components
@onready var sky_projection: MeshInstance3D
@onready var projection_material: ShaderMaterial
@onready var world_environment: WorldEnvironment
@onready var directional_light: DirectionalLight3D

# Advanced Day/Night System (RDR2-inspired)
var original_sky_material: ShaderMaterial
var transition_tween: Tween
var is_day: bool = true

# Sun and moon objects
var sun_object: Node3D = null
var moon_object: Node3D = null
var moon_light: DirectionalLight3D = null

# Celestial movement (realistic distances)
var sun_angle: float = 0.0
var moon_angle: float = 180.0  # Start opposite to sun
var celestial_radius: float = 200.0  # Much farther away (realistic)
var celestial_height: float = 100.0  # Much higher (realistic)

# Cloud movement control
var cloud_speed_multiplier: float = 1.0

# Advanced Day/Night Settings (RDR2-inspired)
@export_group("Advanced Day/Night Settings")
@export var day_night_speed: float = 1.0
@export var transition_smoothness: float = 1.0
@export var atmospheric_intensity: float = 1.0
@export var color_saturation: float = 1.0
@export var light_intensity_multiplier: float = 1.0

# RDR2-style Color Presets
var rdr2_colors = {
	"dawn": {
		"top_color": Color(0.8, 0.4, 0.2, 1.0),      # Warm orange
		"bottom_color": Color(0.6, 0.3, 0.1, 1.0),  # Dark orange
		"light_color": Color(1.0, 0.7, 0.4, 1.0),   # Warm light
		"light_energy": 0.8
	},
	"morning": {
		"top_color": Color(0.6, 0.8, 1.0, 1.0),     # Bright blue
		"bottom_color": Color(0.3, 0.6, 0.9, 1.0),  # Light blue
		"light_color": Color(1.0, 0.95, 0.8, 1.0),  # White light
		"light_energy": 1.2
	},
	"noon": {
		"top_color": Color(0.5, 0.8, 1.0, 1.0),     # Pure blue
		"bottom_color": Color(0.2, 0.6, 0.9, 1.0),  # Deep blue
		"light_color": Color(1.0, 1.0, 0.9, 1.0),   # Bright white
		"light_energy": 1.8
	},
	"evening": {
		"top_color": Color(0.9, 0.5, 0.3, 1.0),     # Warm orange
		"bottom_color": Color(0.7, 0.3, 0.1, 1.0),  # Dark orange
		"light_color": Color(1.0, 0.8, 0.6, 1.0),   # Warm light
		"light_energy": 1.0
	},
	"sunset": {
		"top_color": Color(1.0, 0.3, 0.1, 1.0),     # Bright red
		"bottom_color": Color(0.8, 0.2, 0.05, 1.0), # Dark red
		"light_color": Color(1.0, 0.6, 0.3, 1.0),   # Red light
		"light_energy": 0.8
	},
	"night": {
		"top_color": Color(0.01, 0.01, 0.05, 1.0),  # Deep black-blue
		"bottom_color": Color(0.005, 0.005, 0.02, 1.0), # Pitch black
		"light_color": Color(0.8, 0.85, 1.0, 1.0), # Cool moonlight
		"light_energy": 0.001
	}
}

# Current time of day
var current_time: String = "noon"
var time_progress: float = 0.0  # 0.0 = dawn, 1.0 = night

func _ready():
	setup_sky_projection()
	setup_day_night_system()
	
	# Connect to existing world environment
	world_environment = get_node("../WorldEnvironment")
	if world_environment and world_environment.environment:
		original_sky_material = world_environment.environment.sky.sky_material
		# Ensure day starts bright and vibrant
		if original_sky_material:
			original_sky_material.set_shader_parameter("top_color", Color(0.5, 0.8, 1.0, 1.0))
			original_sky_material.set_shader_parameter("bottom_color", Color(0.2, 0.6, 0.9, 1.0))

func _process(delta):
	update_celestial_movement(delta)

func setup_sky_projection():
	"""Create the floating sky projection system"""
	# Create a large quad for sky projection
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = projection_size
	
	sky_projection = MeshInstance3D.new()
	sky_projection.mesh = quad_mesh
	sky_projection.name = "SkyProjection"
	
	# Create shader material for projection
	var shader = preload("res://sky_projection_shader.gdshader")
	projection_material = ShaderMaterial.new()
	projection_material.shader = shader
	
	sky_projection.material_override = projection_material
	
	# Position the projection in the sky
	sky_projection.position = Vector3(0, projection_height, -projection_distance)
	sky_projection.rotation_degrees = Vector3(0, 0, 0)
	
	# Initially hidden
	sky_projection.visible = false
	
	add_child(sky_projection)

func setup_day_night_system():
	"""Setup day/night transition system"""
	directional_light = get_node("../DirectionalLight3D")
	
	# Ensure day starts bright
	if directional_light:
		directional_light.light_energy = 1.8  # Bright day lighting
	
	# Create sun and moon objects
	create_sun_moon_objects()
	
	# Enable shooting stars in the sky shader
	if original_sky_material:
		original_sky_material.set_shader_parameter("shooting_stars_intensity", 0.0)

func start_presentation():
	"""Begin the presentation mode"""
	if slides.is_empty():
		push_warning("No slides available for presentation")
		return
	
	is_presentation_active = true
	current_slide_index = 0
	show_slide(0)
	presentation_started.emit()
	print("Presentation started with ", slides.size(), " slides")

func end_presentation():
	"""End the presentation mode"""
	is_presentation_active = false
	hide_slide()
	presentation_ended.emit()
	print("Presentation ended")

func next_slide():
	"""Advance to the next slide"""
	if not is_presentation_active or is_transitioning:
		return
	
	current_slide_index = (current_slide_index + 1) % slides.size()
	show_slide(current_slide_index)

func previous_slide():
	"""Go back to the previous slide"""
	if not is_presentation_active or is_transitioning:
		return
	
	current_slide_index = (current_slide_index - 1 + slides.size()) % slides.size()
	show_slide(current_slide_index)

func show_slide(index: int):
	"""Display a specific slide in the sky"""
	if index < 0 or index >= slides.size():
		return
	
	current_slide_index = index
	is_transitioning = true
	
	# Fade out current projection
	if sky_projection.visible:
		fade_projection(0.0, transition_duration * 0.5, func():
			# Change slide texture
			projection_material.set_shader_parameter("slide_texture", slides[index])
			# Fade in new projection
			fade_projection(1.0, transition_duration * 0.5, func():
				is_transitioning = false
			)
		)
	else:
		# First slide - just fade in
		projection_material.set_shader_parameter("slide_texture", slides[index])
		sky_projection.visible = true
		fade_projection(1.0, transition_duration, func():
			is_transitioning = false
		)
	
	slide_changed.emit(index)
	print("Showing slide ", index + 1, " of ", slides.size())

func hide_slide():
	"""Hide the sky projection"""
	if sky_projection.visible:
		fade_projection(0.0, transition_duration, func():
			sky_projection.visible = false
		)

func fade_projection(alpha: float, duration: float, on_complete: Callable = Callable()):
	"""Smoothly fade the projection in/out"""
	if transition_tween:
		transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.tween_method(
		func(a): projection_material.set_shader_parameter("alpha", a),
		projection_material.get_shader_parameter("alpha"),
		alpha,
		duration
	)
	
	if on_complete.is_valid():
		transition_tween.finished.connect(on_complete, CONNECT_ONE_SHOT)

func trigger_day_night_transition():
	"""Trigger the day to night transition with shooting stars"""
	if is_transitioning:
		return
	
	is_transitioning = true
	day_night_transition_started.emit()
	
	# Toggle between day and night
	if is_day:
		transition_to_night()
	else:
		transition_to_day()

func transition_to_night():
	"""Smoothly transition from day to night"""
	if not original_sky_material or not directional_light:
		return
	
	# Set transition state for faster cloud movement
	is_transitioning = true
	cloud_speed_multiplier = 3.0  # 3x faster during transitions
	
	# Update cloud speed in sky shader
	if original_sky_material:
		original_sky_material.set_shader_parameter("cloud_speed_multiplier", cloud_speed_multiplier)
	
	# Create transition tween with smooth easing
	if transition_tween:
		transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.set_parallel(true)
	transition_tween.set_ease(Tween.EASE_IN_OUT)
	transition_tween.set_trans(Tween.TRANS_SINE)  # Ultra-smooth sine transitions for all elements
	
	# RDR2-style night colors (deep black-blue, not yellowish)
	var day_top_color = original_sky_material.get_shader_parameter("top_color")
	var day_bottom_color = original_sky_material.get_shader_parameter("bottom_color")
	var night_top_color = Color(0.01, 0.01, 0.05, 1.0)  # Deep black-blue (RDR2-style)
	var night_bottom_color = Color(0.005, 0.005, 0.02, 1.0)  # Pitch black (RDR2-style)
	
	# Apply atmospheric effects
	night_top_color = apply_atmospheric_effects(night_top_color)
	night_bottom_color = apply_atmospheric_effects(night_bottom_color)
	
	# Ultra-smooth color transitions with intermediate steps (no sudden changes)
	transition_tween.tween_method(
		func(c): original_sky_material.set_shader_parameter("top_color", c),
		day_top_color,
		night_top_color,
		transition_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	transition_tween.tween_method(
		func(c): original_sky_material.set_shader_parameter("bottom_color", c),
		day_bottom_color,
		night_bottom_color,
		transition_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Dim light gradually for smooth night transition
	var original_energy = directional_light.light_energy
	transition_tween.tween_method(
		func(e): directional_light.light_energy = e,
		original_energy,
		0.15,  # Gentle dimming instead of extreme darkness
		transition_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Enable shooting stars with higher intensity
	transition_tween.tween_method(
		func(i): original_sky_material.set_shader_parameter("shooting_stars_intensity", i),
		0.0,
		3.5,  # More visible shooting stars
		transition_duration
	)
	
	# Enable stars with higher intensity
	transition_tween.tween_method(
		func(i): original_sky_material.set_shader_parameter("stars_intensity", i),
		0.0,
		2.5,  # Brighter, more visible stars
		transition_duration
	)
	
	# Add subtle fog effect for night atmosphere
	if original_sky_material.get_shader_parameter("fog_enabled") != null:
		transition_tween.tween_method(
			func(f): original_sky_material.set_shader_parameter("fog_enabled", f),
			false,
			true,
			transition_duration
		)
	
	# Animate sun and moon with proper visibility control
	if sun_object and moon_object:
		# Start with only sun visible
		sun_object.visible = true
		moon_object.visible = false
		moon_object.scale = Vector3.ZERO
		
		# Hide sun gradually (first half of transition)
		var sun_hide_tween = transition_tween.tween_method(
			func(scale): sun_object.scale = Vector3(scale, scale, scale),
			1.0, 0.0, transition_duration * 0.5
		)
		sun_hide_tween.set_ease(Tween.EASE_IN_OUT)
		sun_hide_tween.set_trans(Tween.TRANS_SINE)
		
		# Hide sun completely when scale reaches zero
		sun_hide_tween.finished.connect(func():
			sun_object.visible = false
			moon_object.visible = true
		)
		
		# Show moon gradually (second half of transition)
		var moon_show_tween = transition_tween.tween_method(
			func(scale): moon_object.scale = Vector3(scale, scale, scale),
			0.0, 1.0, transition_duration * 0.5
		).set_delay(transition_duration * 0.5)
		moon_show_tween.set_ease(Tween.EASE_IN_OUT)
		moon_show_tween.set_trans(Tween.TRANS_SINE)
		
		# Enable moon light gradually (synchronized with moon appearance)
		if moon_light:
			var moon_light_tween = transition_tween.tween_method(
				func(energy): moon_light.light_energy = energy,
				0.0, 0.2,  # Gentle moonlight to avoid brightness jumps
				transition_duration * 0.5
			).set_delay(transition_duration * 0.5)  # Synchronized with moon appearance
			moon_light_tween.set_ease(Tween.EASE_IN_OUT)
			moon_light_tween.set_trans(Tween.TRANS_SINE)
	
	transition_tween.finished.connect(func():
		is_day = false
		is_transitioning = false
		cloud_speed_multiplier = 1.0  # Reset cloud speed
		if original_sky_material:
			original_sky_material.set_shader_parameter("cloud_speed_multiplier", cloud_speed_multiplier)
		if sun_object:
			sun_object.visible = false
		day_night_transition_completed.emit()
		print("Day to night transition completed")
	)

func transition_to_day():
	"""Smoothly transition from night to day"""
	if not original_sky_material or not directional_light:
		return
	
	# Set transition state for faster cloud movement
	is_transitioning = true
	cloud_speed_multiplier = 3.0  # 3x faster during transitions
	
	# Update cloud speed in sky shader
	if original_sky_material:
		original_sky_material.set_shader_parameter("cloud_speed_multiplier", cloud_speed_multiplier)
	
	# Create transition tween with smooth easing
	if transition_tween:
		transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.set_parallel(true)
	transition_tween.set_ease(Tween.EASE_IN_OUT)
	transition_tween.set_trans(Tween.TRANS_SINE)  # Ultra-smooth sine transitions for all elements
	
	# RDR2-style day colors (vibrant, realistic)
	var night_top_color = original_sky_material.get_shader_parameter("top_color")
	var night_bottom_color = original_sky_material.get_shader_parameter("bottom_color")
	var day_top_color = Color(0.5, 0.8, 1.0, 1.0)  # RDR2-style bright blue
	var day_bottom_color = Color(0.2, 0.6, 0.9, 1.0)  # RDR2-style vibrant horizon
	
	# Apply atmospheric effects
	day_top_color = apply_atmospheric_effects(day_top_color)
	day_bottom_color = apply_atmospheric_effects(day_bottom_color)
	
	# Ultra-smooth color transitions (no sudden changes)
	transition_tween.tween_method(
		func(c): original_sky_material.set_shader_parameter("top_color", c),
		night_top_color,
		day_top_color,
		transition_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	transition_tween.tween_method(
		func(c): original_sky_material.set_shader_parameter("bottom_color", c),
		night_bottom_color,
		day_bottom_color,
		transition_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Brighten the directional light gradually for smooth day transition
	var current_energy = directional_light.light_energy
	transition_tween.tween_method(
		func(e): directional_light.light_energy = e,
		current_energy,
		1.2,  # Moderate brightness to avoid sudden jumps
		transition_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Disable shooting stars
	transition_tween.tween_method(
		func(i): original_sky_material.set_shader_parameter("shooting_stars_intensity", i),
		original_sky_material.get_shader_parameter("shooting_stars_intensity"),
		0.0,
		transition_duration
	)
	
	# Disable stars
	transition_tween.tween_method(
		func(i): original_sky_material.set_shader_parameter("stars_intensity", i),
		original_sky_material.get_shader_parameter("stars_intensity"),
		0.0,
		transition_duration
	)
	
	# Animate sun and moon back with proper visibility control
	if sun_object and moon_object:
		# Start with only moon visible
		moon_object.visible = true
		sun_object.visible = false
		sun_object.scale = Vector3.ZERO
		
		# Disable moon light gradually (synchronized with moon disappearance)
		if moon_light:
			var moon_light_off_tween = transition_tween.tween_method(
				func(energy): moon_light.light_energy = energy,
				moon_light.light_energy, 0.0,
				transition_duration * 0.5  # Synchronized timing
			)
			moon_light_off_tween.set_ease(Tween.EASE_IN_OUT)
			moon_light_off_tween.set_trans(Tween.TRANS_SINE)
		
		# Hide moon gradually (first half of transition)
		var moon_hide_tween = transition_tween.tween_method(
			func(scale): moon_object.scale = Vector3(scale, scale, scale),
			1.0, 0.0, transition_duration * 0.5
		)
		moon_hide_tween.set_ease(Tween.EASE_IN_OUT)
		moon_hide_tween.set_trans(Tween.TRANS_SINE)
		
		# Hide moon completely when scale reaches zero
		moon_hide_tween.finished.connect(func():
			moon_object.visible = false
			sun_object.visible = true
		)
		
		# Show sun gradually (second half of transition)
		var sun_show_tween = transition_tween.tween_method(
			func(scale): sun_object.scale = Vector3(scale, scale, scale),
			0.0, 1.0, transition_duration * 0.5
		).set_delay(transition_duration * 0.5)
		sun_show_tween.set_ease(Tween.EASE_IN_OUT)
		sun_show_tween.set_trans(Tween.TRANS_SINE)
	
	transition_tween.finished.connect(func():
		is_day = true
		is_transitioning = false
		cloud_speed_multiplier = 1.0  # Reset cloud speed
		if original_sky_material:
			original_sky_material.set_shader_parameter("cloud_speed_multiplier", cloud_speed_multiplier)
		if moon_object:
			moon_object.visible = false
		day_night_transition_completed.emit()
		print("Night to day transition completed")
	)

func add_slide(texture: Texture2D):
	"""Add a new slide to the presentation"""
	slides.append(texture)
	print("Added slide. Total slides: ", slides.size())

func remove_slide(index: int):
	"""Remove a slide from the presentation"""
	if index >= 0 and index < slides.size():
		slides.remove_at(index)
		if current_slide_index >= slides.size():
			current_slide_index = max(0, slides.size() - 1)
		print("Removed slide. Total slides: ", slides.size())

func create_sun_moon_objects():
	"""Create sun and moon objects with RDR2-style circular appearance"""
	# Create sun (RDR2-style warm, circular sun)
	sun_object = Node3D.new()
	sun_object.name = "Sun"
	
	var sun_mesh = SphereMesh.new()
	sun_mesh.radius = 2.5  # Larger, more visible size
	sun_mesh.height = 5.0  # Proper sphere proportions for circle
	
	var sun_mesh_instance = MeshInstance3D.new()
	sun_mesh_instance.mesh = sun_mesh
	
	var sun_material = StandardMaterial3D.new()
	sun_material.albedo_color = Color(1.0, 0.9, 0.7)  # RDR2-style warm golden
	sun_material.emission = Color(1.0, 0.8, 0.4, 1.0)  # Bright golden emission
	sun_material.emission_energy = 2.0  # Strong emission for visibility
	sun_material.flags_unshaded = true  # Always bright
	sun_material.flags_transparent = false  # Solid appearance
	sun_material.flags_use_point_size = true
	sun_material.point_size = 15.0  # Larger, more visible circular sun
	sun_material.albedo_texture = null
	sun_mesh_instance.material_override = sun_material
	
	sun_object.add_child(sun_mesh_instance)
	
	# Position sun using celestial movement
	update_sun_position()
	sun_object.scale = Vector3(1, 1, 1)  # Normal scale
	sun_object.visible = true  # Start with sun visible (day)
	
	add_child(sun_object)
	
	# Create moon (RDR2-style cool, circular moon)
	moon_object = Node3D.new()
	moon_object.name = "Moon"
	
	var moon_mesh = SphereMesh.new()
	moon_mesh.radius = 2.0  # Larger, more visible size
	moon_mesh.height = 4.0  # Proper sphere proportions for circle
	
	var moon_mesh_instance = MeshInstance3D.new()
	moon_mesh_instance.mesh = moon_mesh
	
	var moon_material = StandardMaterial3D.new()
	moon_material.albedo_color = Color(0.95, 0.95, 1.0)  # RDR2-style cool white
	moon_material.emission = Color(0.8, 0.85, 1.0, 0.9)  # Soft blue emission
	moon_material.emission_energy = 1.5  # Moderate emission
	moon_material.flags_unshaded = true  # Always visible
	moon_material.flags_transparent = false  # Solid appearance
	moon_material.flags_use_point_size = true
	moon_material.point_size = 12.0  # Larger, more visible circular moon
	moon_mesh_instance.material_override = moon_material
	
	moon_object.add_child(moon_mesh_instance)
	
	# Create moon light for night illumination
	moon_light = DirectionalLight3D.new()
	moon_light.name = "MoonLight"
	moon_light.light_energy = 0.0  # Start off
	moon_light.light_color = Color(0.8, 0.85, 1.0)  # Cool moonlight
	moon_light.shadow_enabled = true
	moon_object.add_child(moon_light)
	
	# Position moon using celestial movement
	update_moon_position()
	moon_object.scale = Vector3.ZERO  # Start hidden (day)
	moon_object.visible = false  # Start hidden (day)
	
	add_child(moon_object)

func update_celestial_movement(delta: float):
	"""Update sun and moon positions independently"""
	# Move sun very slowly across the sky (realistic speed)
	sun_angle += delta * 0.5  # 0.5 degrees per second (much slower)
	if sun_angle >= 360.0:
		sun_angle -= 360.0
	
	# Move moon very slowly across the sky (opposite direction)
	moon_angle += delta * 0.4  # 0.4 degrees per second (slightly slower)
	if moon_angle >= 360.0:
		moon_angle -= 360.0
	
	# Update positions
	if sun_object:
		update_sun_position()
	if moon_object:
		update_moon_position()

func update_sun_position():
	"""Update sun position based on celestial angle"""
	if not sun_object:
		return
	
	var angle_rad = deg_to_rad(sun_angle)
	var x = sin(angle_rad) * celestial_radius
	var z = cos(angle_rad) * celestial_radius
	var y = celestial_height + sin(angle_rad) * 10.0  # Slight height variation
	
	sun_object.position = Vector3(x, y, z)
	
	# Rotate sun to face the world center
	sun_object.look_at(Vector3.ZERO, Vector3.UP)

func update_moon_position():
	"""Update moon position based on celestial angle"""
	if not moon_object:
		return
	
	var angle_rad = deg_to_rad(moon_angle)
	var x = sin(angle_rad) * celestial_radius
	var z = cos(angle_rad) * celestial_radius
	var y = celestial_height + sin(angle_rad) * 8.0  # Slight height variation
	
	moon_object.position = Vector3(x, y, z)
	
	# Rotate moon to face the world center
	moon_object.look_at(Vector3.ZERO, Vector3.UP)
	
	# Update moon light direction
	if moon_light:
		moon_light.look_at(Vector3.ZERO, Vector3.UP)

func get_current_slide_info() -> Dictionary:
	"""Get information about the current slide"""
	return {
		"index": current_slide_index,
		"total": slides.size(),
		"texture": slides[current_slide_index] if current_slide_index < slides.size() else null,
		"is_active": is_presentation_active
	}

func apply_atmospheric_effects(color: Color) -> Color:
	"""Apply RDR2-style atmospheric effects to colors"""
	# Apply color saturation
	color.r = color.r * color_saturation
	color.g = color.g * color_saturation
	color.b = color.b * color_saturation
	
	# Apply atmospheric intensity
	color.r = color.r * atmospheric_intensity
	color.g = color.g * atmospheric_intensity
	color.b = color.b * atmospheric_intensity
	
	# Clamp values to valid range
	color.r = clamp(color.r, 0.0, 1.0)
	color.g = clamp(color.g, 0.0, 1.0)
	color.b = clamp(color.b, 0.0, 1.0)
	
	return color

func get_rdr2_time_colors(time: String) -> Dictionary:
	"""Get RDR2-style colors for specific time of day"""
	if time in rdr2_colors:
		return rdr2_colors[time]
	return rdr2_colors["noon"]  # Default to noon

func update_time_progression():
	"""Update time progression based on celestial movement"""
	# Calculate time based on sun angle (use fmod for float modulo)
	time_progress = fmod(sun_angle / 360.0, 1.0)
	
	# Determine current time of day
	if time_progress < 0.1:
		current_time = "dawn"
	elif time_progress < 0.3:
		current_time = "morning"
	elif time_progress < 0.5:
		current_time = "noon"
	elif time_progress < 0.7:
		current_time = "evening"
	elif time_progress < 0.9:
		current_time = "sunset"
	else:
		current_time = "night"
