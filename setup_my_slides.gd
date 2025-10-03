extends Node

# Quick script to set up your presentation slides
# Add this to your main scene and run it

func _ready():
	setup_presentation_slides()

func setup_presentation_slides():
	"""Set up your presentation slides"""
	var presentation_manager = get_node("PresentationManager")
	if not presentation_manager:
		print("PresentationManager not found!")
		return
	
	# Clear any existing slides
	presentation_manager.slides.clear()
	
	# Add your slides here - replace with your actual slide paths
	var slide_paths = [
		"res://slides/slide1.png",
		"res://slides/slide2.png", 
		"res://slides/slide3.png",
		"res://slides/slide4.png",
		"res://slides/slide5.png"
	]
	
	# Load and add each slide
	for slide_path in slide_paths:
		var texture = load(slide_path) as Texture2D
		if texture:
			presentation_manager.add_slide(texture)
			print("Added slide: ", slide_path)
		else:
			print("Failed to load: ", slide_path)
	
	print("✅ Presentation setup complete with ", presentation_manager.slides.size(), " slides")
	print("🎮 Walk to the 'Start Presentation' button and press E to begin!")
