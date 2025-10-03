extends Control
class_name DayNightIndicator

# Simple UI indicator to show current day/night state
# Helps with testing the day/night transitions

@onready var status_label: Label
@onready var instruction_label: Label

var presentation_manager: PresentationManager = null

func _ready():
	setup_ui()
	find_presentation_manager()

func setup_ui():
	"""Setup the UI elements"""
	# Main container
	var vbox = VBoxContainer.new()
	vbox.anchors_preset = Control.PRESET_TOP_RIGHT
	vbox.offset_right = -20
	vbox.offset_top = 20
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	
	# Status label
	status_label = Label.new()
	status_label.text = "Time: Day"
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.modulate = Color.WHITE
	vbox.add_child(status_label)
	
	# Instruction label
	instruction_label = Label.new()
	instruction_label.text = "Press I to toggle day/night"
	instruction_label.add_theme_font_size_override("font_size", 14)
	instruction_label.modulate = Color.LIGHT_GRAY
	vbox.add_child(instruction_label)

func find_presentation_manager():
	"""Find the presentation manager"""
	presentation_manager = get_node("../PresentationManager")
	if not presentation_manager:
		presentation_manager = get_node("../../PresentationManager")
	
	if presentation_manager:
		# Connect to presentation manager signals
		presentation_manager.day_night_transition_started.connect(_on_transition_started)
		presentation_manager.day_night_transition_completed.connect(_on_transition_completed)

func _on_transition_started():
	"""Handle transition start"""
	status_label.text = "Time: Transitioning..."
	status_label.modulate = Color.YELLOW

func _on_transition_completed():
	"""Handle transition completion"""
	if presentation_manager:
		if presentation_manager.is_day:
			status_label.text = "Time: Day"
			status_label.modulate = Color.CYAN
		else:
			status_label.text = "Time: Night"
			status_label.modulate = Color.PURPLE
