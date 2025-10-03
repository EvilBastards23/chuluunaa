extends Node
class_name PresentationSetup

# Helper script to set up presentation slides and configure the system
# This script can be used to easily add slides and configure the presentation

@export var slide_textures: Array[Texture2D] = []
@export var auto_setup_on_ready: bool = true

var presentation_manager: PresentationManager = null

func _ready():
	if auto_setup_on_ready:
		setup_presentation()

func setup_presentation():
	"""Setup the presentation with the configured slides"""
	find_presentation_manager()
	
	if presentation_manager:
		# Clear existing slides
		presentation_manager.slides.clear()
		
		# Add configured slides
		for texture in slide_textures:
			if texture:
				presentation_manager.add_slide(texture)
		
		print("Presentation setup complete with ", slide_textures.size(), " slides")
	else:
		push_warning("PresentationManager not found!")

func find_presentation_manager():
	"""Find the presentation manager in the scene"""
	presentation_manager = get_node("../PresentationManager")
	if not presentation_manager:
		presentation_manager = get_node("../../PresentationManager")
	if not presentation_manager:
		presentation_manager = get_node("../../../PresentationManager")

func add_slide_from_path(texture_path: String):
	"""Add a slide from a file path"""
	var texture = load(texture_path) as Texture2D
	if texture:
		slide_textures.append(texture)
		if presentation_manager:
			presentation_manager.add_slide(texture)
		print("Added slide: ", texture_path)
	else:
		push_error("Failed to load texture: ", texture_path)

func add_slide_from_texture(texture: Texture2D):
	"""Add a slide from a Texture2D resource"""
	if texture:
		slide_textures.append(texture)
		if presentation_manager:
			presentation_manager.add_slide(texture)
		print("Added slide texture")

func remove_slide(index: int):
	"""Remove a slide by index"""
	if index >= 0 and index < slide_textures.size():
		slide_textures.remove_at(index)
		if presentation_manager:
			presentation_manager.remove_slide(index)
		print("Removed slide at index: ", index)

func clear_all_slides():
	"""Clear all slides"""
	slide_textures.clear()
	if presentation_manager:
		presentation_manager.slides.clear()
	print("Cleared all slides")

func get_slide_count() -> int:
	"""Get the number of configured slides"""
	return slide_textures.size()

func get_presentation_info() -> Dictionary:
	"""Get information about the current presentation setup"""
	var info = {
		"slide_count": slide_textures.size(),
		"has_presentation_manager": presentation_manager != null,
		"slides": []
	}
	
	for i in range(slide_textures.size()):
		info.slides.append({
			"index": i,
			"texture": slide_textures[i],
			"path": slide_textures[i].resource_path if slide_textures[i] else ""
		})
	
	return info

# Example usage functions for common setups
func setup_demo_presentation():
	"""Setup a demo presentation with placeholder slides"""
	clear_all_slides()
	
	# Create placeholder textures for demo
	var demo_slides = []
	
	# You can replace these with actual slide textures
	# For now, we'll create simple colored rectangles as placeholders
	for i in range(5):
		var image = Image.create(800, 600, false, Image.FORMAT_RGB8)
		var color = Color.from_hsv(i * 0.2, 0.7, 0.8)
		image.fill(color)
		
		var texture = ImageTexture.new()
		texture.set_image(image)
		
		demo_slides.append(texture)
	
	# Add demo slides
	for slide in demo_slides:
		add_slide_from_texture(slide)
	
	print("Demo presentation setup with 5 placeholder slides")

func setup_from_folder(folder_path: String):
	"""Setup presentation by loading all images from a folder"""
	clear_all_slides()
	
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
				var full_path = folder_path + "/" + file_name
				add_slide_from_path(full_path)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
		print("Loaded slides from folder: ", folder_path)
	else:
		push_error("Could not open folder: ", folder_path)
