extends Node

# Setup script for seashell projector presentation system
# Connects the seashell projector with the presentation controls

func _ready():
	setup_seashell_presentation()

func setup_seashell_presentation():
	"""Setup the seashell projector with presentation system"""
	var presentation_manager = get_node("PresentationManager")
	var seashell_projector = get_node("SeashellProjector")
	
	if not presentation_manager or not seashell_projector:
		print("❌ Missing components!")
		return
	
	# Connect presentation manager to seashell projector
	presentation_manager.slide_changed.connect(_on_slide_changed)
	presentation_manager.presentation_started.connect(_on_presentation_started)
	presentation_manager.presentation_ended.connect(_on_presentation_ended)
	
	# Connect seashell projector to presentation manager
	seashell_projector.slide_changed.connect(_on_seashell_slide_changed)
	
	# Copy slides from presentation manager to seashell projector
	for slide in presentation_manager.slides:
		seashell_projector.add_slide(slide)
	
	print("🐚 Seashell projector connected to presentation system!")
	print("📖 Book location: X=30, Y=2, Z=15")
	print("🐚 Seashell projector location: X=35, Y=2, Z=25")

func _on_slide_changed(slide_index: int):
	"""Handle slide change from presentation manager"""
	var seashell_projector = get_node("SeashellProjector")
	if seashell_projector and seashell_projector.is_active:
		seashell_projector.show_slide(slide_index)

func _on_presentation_started():
	"""Handle presentation start"""
	var seashell_projector = get_node("SeashellProjector")
	if seashell_projector:
		seashell_projector.activate_projector()
		seashell_projector.show_slide(0)

func _on_presentation_ended():
	"""Handle presentation end"""
	var seashell_projector = get_node("SeashellProjector")
	if seashell_projector:
		seashell_projector.deactivate_projector()

func _on_seashell_slide_changed(slide_index: int):
	"""Handle slide change from seashell projector"""
	print("🐚 Seashell showing slide: ", slide_index + 1)

# Customization functions
func customize_seashell_projector():
	"""Example of how to customize the seashell projector"""
	var seashell_projector = get_node("SeashellProjector")
	if not seashell_projector:
		return
	
	# Customize projection settings
	seashell_projector.set_projection_width(10.0)  # Wider projection
	seashell_projector.set_projection_height(7.5)  # Taller projection
	seashell_projector.set_projection_distance(20.0)  # Project further
	seashell_projector.set_projection_angle(15.0)  # Angle the projection
	seashell_projector.set_projection_intensity(1.5)  # Brighter projection
	seashell_projector.set_projection_color(Color(1.0, 0.9, 0.8))  # Warm color tint
	
	print("🐚 Seashell projector customized!")

func add_demo_slides():
	"""Add demo slides to test the system"""
	var presentation_manager = get_node("PresentationManager")
	var seashell_projector = get_node("SeashellProjector")
	
	if not presentation_manager or not seashell_projector:
		return
	
	# Clear existing slides
	presentation_manager.slides.clear()
	seashell_projector.slides.clear()
	
	# Create demo slides
	for i in range(5):
		var image = Image.create(800, 600, false, Image.FORMAT_RGB8)
		var color = Color.from_hsv(i * 0.2, 0.7, 0.9)
		image.fill(color)
		
		var texture = ImageTexture.new()
		texture.set_image(image)
		
		presentation_manager.add_slide(texture)
		seashell_projector.add_slide(texture)
	
	print("🐚 Added 5 demo slides to both systems!")
