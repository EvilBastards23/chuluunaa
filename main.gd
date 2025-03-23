extends Node3D
@onready var multiplayer_ui = $UI/Multiplayer
@export var player_scene = PackedScene
var peer = ENetMultiplayerPeer.new()
var PLAYER = preload("res://player.tscn")
func _on_host_2_pressed() -> void:
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(
		func(id):
			print("Peer " + str(id) + " has joined the game")
			add_player(id)  # Pass the connected peer's ID
	)
	add_player(multiplayer.get_unique_id())  # Add the host player
	multiplayer_ui.hide()

func _on_join_pressed() -> void:
	peer.create_client("127.0.0.1", 1027)
	multiplayer.multiplayer_peer = peer
	
	multiplayer_ui.hide()

func add_player(id = 1):  # Accept `pid` as a parameter
	var player = PLAYER.instantiate()
	player.name = str(id)  # Set the player's name as their unique ID
	call_deferred("add_child",player)
func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)
func del_player(id):
	rpc("del_player",id)
@rpc("any_peer","call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
	
