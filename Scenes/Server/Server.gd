extends Node

# This file is only initialized and ran on the server

signal start_game()

@export var game_status_label: Label
@export var peers_label: Label

enum GameState {
	PRE_GAME,
	IN_PROGRESS,
	POST_GAME,
}

var enet = ENetMultiplayerPeer.new()
var game_state = GameState.PRE_GAME
var peers: Array[int] = []

func _enter_tree():
	set_multiplayer_authority(1)

func _ready() -> void:
	if not is_multiplayer_authority(): return
	
	print("Creating server")
	var err = enet.create_server(Global.PORT, 2)
	if err:
		print("Failed to create server")
		return

	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.multiplayer_peer = enet
	render()
	
func on_peer_connected(id: int) -> void:
	print("[1] peer '%s' connected" % id)
	peers.append(id)
	print("[1] peers ", peers)
	render()
	
	if len(peers) == 2:
		create_world_on_all_clients_and_server()

func on_peer_disconnected(id: int) -> void:
	print("[1] peer '%s' disconnected" % id)
	peers.erase(id)
	print("[1] peers ", peers)
	render()

func render() -> void:
	game_status_label.text = str(game_state)
	peers_label.text = str(peers)

func create_world_on_all_clients_and_server() -> void:
	print("[1] create_world_on_all_clients_and_server")
	start_game.emit()
