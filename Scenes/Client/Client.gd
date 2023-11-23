extends Node

# This file is only initialized and ran on the client

var enet = ENetMultiplayerPeer.new()
var my_id: int = 0

func _ready() -> void:
	print("Creating client")
	var err = enet.create_client(Global.SERVER_ADDRESS, Global.PORT)
	if err:
		print("Failed to create client")
	
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.multiplayer_peer = enet
	my_id = enet.get_unique_id()

func on_peer_connected(id: int) -> void:
	print("[%s] peer '%s' connected" % [my_id , id])

func on_peer_disconnected(id: int) -> void:
	print("[%s] peer '%s' disconnected" % [my_id, id])
	
func on_connected_to_server() -> void:
	print("[%s] on_connected_to_server called" % my_id)
	
func on_connection_failed() -> void:
	print("[%s] on_connection_failed called" % my_id)
	
func on_server_disconnected() -> void:
	print("[%s] on_server_disconnected called" % my_id)
