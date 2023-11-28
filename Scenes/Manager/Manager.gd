extends Node

@onready var main_menu_ui = $MainMenuUI

var enet = ENetMultiplayerPeer.new()
var peers: Array[int] = []
var peer_name_map: Dictionary = {} ## Dictionary<peer_id:int, name:String>
var my_id: int = 0
var world: Node3D

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		on_create_server_pressed()
	else:
		main_menu_ui.join_server_pressed.connect(on_join_server_pressed)
		main_menu_ui.create_server_pressed.connect(on_create_server_pressed)
		main_menu_ui.cancel_join_pressed.connect(on_cancel_join_pressed)
		main_menu_ui.update_status_label("")

func on_cancel_join_pressed() -> void:
	enet.close()
	print("cancelled")
	main_menu_ui.update_status_label("")
	main_menu_ui.enable_join_btn()
	main_menu_ui.cancel_btn.hide()
	multiplayer.connected_to_server.disconnect(on_connected_to_server)
	multiplayer.connection_failed.disconnect(on_connection_failed)
	multiplayer.server_disconnected.disconnect(on_server_disconnected)
	multiplayer.peer_connected.disconnect(on_peer_connected)
	multiplayer.peer_disconnected.disconnect(on_peer_disconnected)

func on_join_server_pressed() -> void:
	print("Creating client")
	var err = enet.create_client(Global.SERVER_ADDRESS, Global.PORT)
	if err:
		print("Failed to create client")
		
	main_menu_ui.update_status_label("Connecting...")
	
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.multiplayer_peer = enet
	my_id = enet.get_unique_id()

func on_create_server_pressed() -> void:
	print("Creating server")
	var err = enet.create_server(Global.PORT, 2)
	if err:
		print("Failed to create server")
		return

	multiplayer.peer_connected.connect(on_peer_connected_to_server)
	multiplayer.peer_disconnected.connect(on_peer_disconnected_to_server)
	multiplayer.multiplayer_peer = enet
	my_id = enet.get_unique_id()
	main_menu_ui.hide()

@rpc("call_local")
func sync_peer_name_map(map: Dictionary) -> void:
	world.synced_peer_name_map = map

@rpc("any_peer")
func send_display_name(display_name: String) -> void:
	if not multiplayer.is_server(): return
	
	var id = multiplayer.get_remote_sender_id()
	peer_name_map[id] = display_name
	
	if peer_name_map.size() == 2:
		sync_peer_name_map.rpc(peer_name_map)

@rpc("call_local")
func create_world(player1: int, player2: int) -> void:
	print("[%s] Create world called" % multiplayer.get_unique_id())
	main_menu_ui.hide()
	var world_scene = load("res://Scenes/World/World.tscn")
	world = world_scene.instantiate()
	world.player_1_id = player1
	world.player_2_id = player2
	if my_id == player1:
		world.player = world.PLAYER.ONE
	elif my_id == player2:
		world.player = world.PLAYER.TWO
	else:
		world.player = world.PLAYER.SERVER
	add_child(world)

func on_peer_connected_to_server(id: int) -> void:
	print("[1] peer '%s' connected" % id)
	peers.append(id)
	print("[1] peers ", peers)
	
	if len(peers) == 2:
		create_world.rpc(peers[0], peers[1])
		enet.refuse_new_connections = true

func on_peer_disconnected_to_server(id: int) -> void:
	print("[1] peer '%s' disconnected" % id)
	peers.erase(id)
	peer_name_map.erase(id)
	print("[1] peers ", peers)
	if peers.size() < 2:
		enet.refuse_new_connections = false
	
func on_peer_connected(id: int) -> void:
	print("[%s] peer '%s' connected" % [my_id , id])

func on_peer_disconnected(id: int) -> void:
	print("[%s] peer '%s' disconnected" % [my_id, id])
	
func on_connected_to_server() -> void:
	print("[%s] on_connected_to_server called" % my_id)
	main_menu_ui.update_status_label("Connected to server. Waiting for other player...")
	send_display_name.rpc(main_menu_ui.name_input.text)
	
func on_connection_failed() -> void:
	print("[%s] on_connection_failed called" % my_id)
	main_menu_ui.update_status_label("Failed to connect to server")
	main_menu_ui.enable_join_btn()
	
func on_server_disconnected() -> void:
	print("[%s] on_server_disconnected called" % my_id)
