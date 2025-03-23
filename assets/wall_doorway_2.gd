extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var area = $Area3D  # Reference to the Area3D node

var has_played_animation = false  # Track if animation has already played

func _ready():
	area.body_entered.connect(_on_body_entered)  # Connect body_entered signal to function

func _on_body_entered(body):
	# Ensure the body is the player (CharacterBody3D) and animation hasn't already played
	if body is CharacterBody3D and not has_played_animation:
		has_played_animation = true  # Mark animation as played
		play_door_animation()  # Play the door animation when the player enters the area

func play_door_animation():
	if animation_player.is_playing():
		return  # Prevent restarting the animation if already playing
	animation_player.play("door open_and_close")  # Play the door open/close animation
