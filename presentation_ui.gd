extends Control
class_name PresentationUI

# UI overlay for presentation controls and information
# Shows slide information, controls, and status

@onready var slide_info_label: Label
@onready var interaction_hint_label: Label
@onready var presentation_status_label: Label
@onready var book_status_label: Label

var presentation_manager: PresentationManager = null
var is_visible: bool = false

func _ready():
	setup_ui()
	find_presentation_manager()

func setup_ui():
	"""Setup the UI elements"""
	# Main container
	var vbox = VBoxContainer.new()
	vbox.anchors_preset = Control.PRESET_TOP_LEFT
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	
	# Slide information
	slide_info_label = Label.new()
	slide_info_label.text = "Slide: 0 / 0"
	slide_info_label.add_theme_font_size_override("font_size", 18)
	slide_info_label.modulate = Color.WHITE
	vbox.add_child(slide_info_label)
	
	# Presentation status
	presentation_status_label = Label.new()
	presentation_status_label.text = "Presentation: Ready"
	presentation_status_label.add_theme_font_size_override("font_size", 16)
	presentation_status_label.modulate = Color.LIGHT_GRAY
	vbox.add_child(presentation_status_label)
	
	# Book status
	book_status_label = Label.new()
	book_status_label.text = "Book: Not placed"
	book_status_label.add_theme_font_size_override("font_size", 16)
	book_status_label.modulate = Color.LIGHT_GRAY
	vbox.add_child(book_status_label)
	
	# Interaction hints (bottom right)
	var hint_container = VBoxContainer.new()
	hint_container.anchors_preset = Control.PRESET_BOTTOM_RIGHT
	hint_container.offset_right = -20
	hint_container.offset_bottom = -20
	hint_container.add_theme_constant_override("separation", 5)
	add_child(hint_container)
	
	interaction_hint_label = Label.new()
	interaction_hint_label.text = "Press E to interact"
	interaction_hint_label.add_theme_font_size_override("font_size", 14)
	interaction_hint_label.modulate = Color.YELLOW
	interaction_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint_container.add_child(interaction_hint_label)
	
	# Initially hidden
	visible = false

func find_presentation_manager():
	"""Find the presentation manager in the scene"""
	presentation_manager = get_node("../PresentationManager")
	if not presentation_manager:
		presentation_manager = get_node("../../PresentationManager")
	
	if presentation_manager:
		# Connect to presentation manager signals
		presentation_manager.slide_changed.connect(_on_slide_changed)
		presentation_manager.presentation_started.connect(_on_presentation_started)
		presentation_manager.presentation_ended.connect(_on_presentation_ended)
		presentation_manager.day_night_transition_started.connect(_on_day_night_transition_started)
		presentation_manager.day_night_transition_completed.connect(_on_day_night_transition_completed)

func show_ui():
	"""Show the presentation UI"""
	visible = true
	is_visible = true

func hide_ui():
	"""Hide the presentation UI"""
	visible = false
	is_visible = false

func update_slide_info():
	"""Update the slide information display"""
	if presentation_manager:
		var info = presentation_manager.get_current_slide_info()
		slide_info_label.text = "Slide: %d / %d" % [info.index + 1, info.total]
		
		if info.is_active:
			slide_info_label.modulate = Color.GREEN
		else:
			slide_info_label.modulate = Color.WHITE

func update_presentation_status(status: String, color: Color = Color.WHITE):
	"""Update the presentation status display"""
	presentation_status_label.text = "Presentation: " + status
	presentation_status_label.modulate = color

func update_book_status(status: String, color: Color = Color.WHITE):
	"""Update the book status display"""
	book_status_label.text = "Book: " + status
	book_status_label.modulate = color

func update_interaction_hint(hint: String):
	"""Update the interaction hint"""
	interaction_hint_label.text = hint

func _on_slide_changed(slide_index: int):
	"""Handle slide change"""
	update_slide_info()

func _on_presentation_started():
	"""Handle presentation start"""
	update_presentation_status("Active", Color.GREEN)
	show_ui()

func _on_presentation_ended():
	"""Handle presentation end"""
	update_presentation_status("Stopped", Color.RED)

func _on_day_night_transition_started():
	"""Handle day/night transition start"""
	update_book_status("Placed - Transitioning...", Color.YELLOW)

func _on_day_night_transition_completed():
	"""Handle day/night transition completion"""
	update_book_status("Placed - Night Mode", Color.GREEN)

func set_interaction_hint_for_control(control_name: String):
	"""Set interaction hint for a specific control"""
	match control_name.to_lower():
		"next slide":
			update_interaction_hint("Press E - Next Slide")
		"previous slide":
			update_interaction_hint("Press E - Previous Slide")
		"start presentation":
			update_interaction_hint("Press E - Start Presentation")
		"stop presentation":
			update_interaction_hint("Press E - Stop Presentation")
		"book":
			update_interaction_hint("Press E - Pick up/Drop Book")
		_:
			update_interaction_hint("Press E to interact")

func clear_interaction_hint():
	"""Clear the interaction hint"""
	update_interaction_hint("Press E to interact")
