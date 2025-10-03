extends Node
class_name QuickSetup

# Quick setup script to get your presentation system running immediately
# Run this script to create a demo presentation with placeholder slides

@export var create_demo_slides: bool = true
@export var demo_slide_count: int = 5
@export var setup_controls: bool = true
@export var setup_book: bool = true

func _ready():
	if create_demo_slides:
		setup_demo_presentation()
	
	if setup_controls:
		setup_controls_positions()
	
	if setup_book:
		setup_book_placement()
	
	print("🎮 Presentation system setup complete!")
	print("📖 Check the PRESENTATION_README.md for detailed instructions")
	print("🎯 Press E near controls to interact, pick up the book to trigger day/night transition")

func setup_demo_presentation():
	"""Create a demo presentation with placeholder slides"""
	var presentation_manager = find_presentation_manager()
	if not presentation_manager:
		push_error("PresentationManager not found!")
		return
	
	# Clear existing slides
	presentation_manager.slides.clear()
	
	# Create demo slides with different colors and text
	for i in range(demo_slide_count):
		var slide_texture = create_demo_slide(i + 1)
		presentation_manager.add_slide(slide_texture)
	
	print("✅ Created ", demo_slide_count, " demo slides")

func create_demo_slide(slide_number: int) -> ImageTexture:
	"""Create a demo slide with text and color"""
	var image = Image.create(800, 600, false, Image.FORMAT_RGB8)
	
	# Create gradient background
	var base_color = Color.from_hsv((slide_number - 1) * 0.2, 0.6, 0.9)
	var dark_color = base_color.darkened(0.3)
	
	# Fill with gradient
	for y in range(600):
		var t = float(y) / 600.0
		var color = base_color.lerp(dark_color, t)
		for x in range(800):
			image.set_pixel(x, y, color)
	
	# Add text (simple pixel-based text)
	var text = "Slide " + str(slide_number)
	var text_color = Color.WHITE
	
	# Simple text rendering (you can replace this with proper text rendering)
	var start_x = 400 - (text.length() * 8)
	var start_y = 300
	
	for i in range(text.length()):
		var char = text[i]
		draw_simple_char(image, char, start_x + i * 16, start_y, text_color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func draw_simple_char(image: Image, char: String, x: int, y: int, color: Color):
	"""Draw a simple character (placeholder - you can improve this)"""
	# Simple 8x8 pixel font representation
	var char_data = get_char_pixels(char)
	
	for py in range(8):
		for px in range(8):
			if char_data[py][px] == 1:
				var pixel_x = x + px
				var pixel_y = y + py
				if pixel_x >= 0 and pixel_x < 800 and pixel_y >= 0 and pixel_y < 600:
					image.set_pixel(pixel_x, pixel_y, color)

func get_char_pixels(char: String) -> Array:
	"""Get pixel data for a character (simplified)"""
	# This is a very basic font representation
	# You can replace this with a proper font system
	match char:
		"S":
			return [
				[0,1,1,1,1,1,0,0],
				[1,1,0,0,0,1,1,0],
				[1,1,0,0,0,0,0,0],
				[0,1,1,1,1,1,0,0],
				[0,0,0,0,0,1,1,0],
				[1,1,0,0,0,1,1,0],
				[0,1,1,1,1,1,0,0],
				[0,0,0,0,0,0,0,0]
			]
		"l":
			return [
				[1,1,0,0,0,0,0,0],
				[1,1,0,0,0,0,0,0],
				[1,1,0,0,0,0,0,0],
				[1,1,0,0,0,0,0,0],
				[1,1,0,0,0,0,0,0],
				[1,1,0,0,0,0,0,0],
				[1,1,1,1,1,1,0,0],
				[0,0,0,0,0,0,0,0]
			]
		"i":
			return [
				[0,0,1,1,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,1,1,0,0,0,0],
				[0,0,1,1,0,0,0,0],
				[0,0,1,1,0,0,0,0],
				[0,0,1,1,0,0,0,0],
				[0,0,1,1,0,0,0,0],
				[0,0,0,0,0,0,0,0]
			]
		"d":
			return [
				[0,0,0,0,1,1,0,0],
				[0,0,0,0,1,1,0,0],
				[0,1,1,1,1,1,0,0],
				[1,1,0,0,1,1,0,0],
				[1,1,0,0,1,1,0,0],
				[1,1,0,0,1,1,0,0],
				[0,1,1,1,1,1,0,0],
				[0,0,0,0,0,0,0,0]
			]
		"e":
			return [
				[0,1,1,1,1,1,0,0],
				[1,1,0,0,0,0,0,0],
				[1,1,1,1,1,0,0,0],
				[1,1,0,0,0,0,0,0],
				[1,1,0,0,0,0,0,0],
				[1,1,0,0,0,0,0,0],
				[0,1,1,1,1,1,0,0],
				[0,0,0,0,0,0,0,0]
			]
		" ":
			return [
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0]
			]
		_:
			# Default character (square)
			return [
				[1,1,1,1,1,1,1,0],
				[1,0,0,0,0,0,1,0],
				[1,0,0,0,0,0,1,0],
				[1,0,0,0,0,0,1,0],
				[1,0,0,0,0,0,1,0],
				[1,0,0,0,0,0,1,0],
				[1,1,1,1,1,1,1,0],
				[0,0,0,0,0,0,0,0]
			]

func setup_controls_positions():
	"""Set up control positions for easy access"""
	var controls = [
		{"name": "NextSlideControl", "pos": Vector3(40, 1.5, 20)},
		{"name": "PreviousSlideControl", "pos": Vector3(37, 1.5, 20)},
		{"name": "StartPresentationControl", "pos": Vector3(43, 1.5, 20)},
		{"name": "StopPresentationControl", "pos": Vector3(46, 1.5, 20)}
	]
	
	for control_info in controls:
		var control = get_node_or_null("../PresentationScene/" + control_info.name)
		if control:
			control.global_position = control_info.pos
			print("✅ Positioned ", control_info.name)

func setup_book_placement():
	"""Set up book and placement area"""
	var book = get_node_or_null("../PresentationScene/PresentationBook")
	if book:
		# Position book in a storage area
		book.global_position = Vector3(30, 2, 15)
		
		# Set placement area near the presentation controls
		book.set_placement_area_position(Vector3(42, 1, 18))
		print("✅ Set up book placement area")

func find_presentation_manager() -> PresentationManager:
	"""Find the presentation manager"""
	return get_node_or_null("../PresentationScene/PresentationManager")

func add_your_slides():
	"""Template function for adding your own slides"""
	var presentation_manager = find_presentation_manager()
	if not presentation_manager:
		return
	
	# Example: Add your own slides
	# presentation_manager.add_slide(load("res://your_slides/slide1.png"))
	# presentation_manager.add_slide(load("res://your_slides/slide2.png"))
	# presentation_manager.add_slide(load("res://your_slides/slide3.png"))
	
	print("📝 Add your slides by modifying the add_your_slides() function")
	print("📁 Or use setup_from_folder() to load all images from a directory")
