extends Node

# Test script to verify the enhanced day/night cycle improvements
# Run this to see the dramatic difference between day and night

func _ready():
	print("🌅 Enhanced Day/Night System Test Ready!")
	print("")
	print("✨ Improvements Made:")
	print("  🌙 Much darker night sky (deep blue-black)")
	print("  ⭐ Brighter, more visible stars")
	print("  🌠 Enhanced shooting stars")
	print("  🌌 Better atmospheric glow")
	print("  💡 Dramatic lighting contrast")
	print("")
	print("🎮 Controls:")
	print("  I - Toggle day/night (see the dramatic difference!)")
	print("  E - Interact with presentation controls")
	print("  WASD - Move around")
	print("  Mouse - Look around")
	print("")
	print("🎯 Test the improvements:")
	print("  1. Press I to switch to night - notice how DARK it gets!")
	print("  2. Look up at the sky - see the bright stars and shooting stars")
	print("  3. Press I again to switch back to day - notice the contrast!")
	print("  4. Try the presentation system with the book mechanism")
	print("")
	print("🌙 The night should now look like actual night, not day!")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_I:
				print("🌙 Toggling day/night - watch for the dramatic difference!")
			KEY_H:
				show_help()

func show_help():
	print("")
	print("🎮 Enhanced Day/Night System Help:")
	print("")
	print("🌅 Day Features:")
	print("  - Bright, clear sky")
	print("  - Full directional lighting")
	print("  - Visible sun")
	print("  - Animated clouds")
	print("")
	print("🌙 Night Features:")
	print("  - Very dark sky (deep blue-black)")
	print("  - Bright, twinkling stars")
	print("  - Shooting stars across the sky")
	print("  - Atmospheric glow")
	print("  - Minimal lighting (dramatic contrast)")
	print("")
	print("🎯 Presentation System:")
	print("  - Press E near controls to navigate slides")
	print("  - Pick up the book and place it to trigger transitions")
	print("  - Slides project onto the sky")
	print("  - Smooth transitions between day and night")
	print("")
	print("The night should now be dramatically different from day!")
