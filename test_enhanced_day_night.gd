extends Node

# Test script for the enhanced day/night system
# Shows you all the new features

func _ready():
	print("🌅 Enhanced Day/Night System Ready!")
	print("🎮 Press 'I' to toggle between day and night")
	print("")
	print("✨ New Features:")
	print("  🌞 Sun smoothly disappears/appears")
	print("  🌙 Moon smoothly appears/disappears in center of sky")
	print("  🌌 Realistic countryside night sky (dark blue)")
	print("  ☁️ Enhanced animated clouds with multiple layers")
	print("  ⭐ Shooting stars during night")
	print("  🌟 Twinkling stars")
	print("")
	print("🎯 Test the smoothness by pressing 'I' multiple times!")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_I:
				print("🌙 Toggling day/night...")
			KEY_H:
				show_help()

func show_help():
	print("")
	print("🎮 Controls:")
	print("  I - Toggle day/night")
	print("  E - Interact with buttons/book")
	print("  WASD - Move")
	print("  Mouse - Look around")
	print("  Shift - Sprint")
	print("  Space - Jump")
	print("")
	print("🌅 Day Features:")
	print("  - Bright blue sky")
	print("  - Visible sun")
	print("  - Animated clouds")
	print("")
	print("🌙 Night Features:")
	print("  - Dark blue countryside sky")
	print("  - Visible moon in center")
	print("  - Twinkling stars")
	print("  - Shooting stars")
	print("  - Enhanced cloud animation")
