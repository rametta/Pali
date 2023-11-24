extends Node

@onready var main_menu_ui = $MainMenuUI

var enet = ENetMultiplayerPeer.new()
var peers: Array[int] = []
var peers_intro_done: Array[int] = []
var peers_start_cards_tween_done: Array[int] = []
var my_id: int = 0
var world: Node3D

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		on_create_server_pressed()
	else:
		main_menu_ui.join_server_pressed.connect(on_join_server_pressed)
		main_menu_ui.create_server_pressed.connect(on_create_server_pressed)
		main_menu_ui.update_status_label("")
		
func on_join_server_pressed(display_name: String):
	print("Join server btn pressed with name %s" % display_name)
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

func on_create_server_pressed():
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

func on_start_game():
	create_world.rpc()

@rpc("call_local")
func create_world(player1: int, player2: int) -> void:
	print("[%s] Create world called" % multiplayer.get_unique_id())
	main_menu_ui.hide()
	var world_scene = load("res://Scenes/World/World.tscn")
	world = world_scene.instantiate()
	if my_id == player1:
		world.player = GlobalServer.PLAYER.ONE
	elif my_id == player2:
		world.player = GlobalServer.PLAYER.TWO
	else:
		world.player = GlobalServer.PLAYER.SERVER
	add_child(world)
	world.intro_done.connect(on_intro_done)
	world.start_cards_tween_done.connect(on_start_cards_tween_done)
	world.card_played.connect(on_card_played)
	
@rpc("any_peer")
func on_card_played_server(id: int) -> void:
	if not multiplayer.is_server(): return
	
	if id == peers[0]:
		GlobalServer.update_player_turn.rpc(GlobalServer.PLAYER.TWO)
	elif id == peers[1]:
		GlobalServer.update_player_turn.rpc(GlobalServer.PLAYER.ONE)
	
func on_card_played() -> void:
	on_card_played_server.rpc(my_id)
	
@rpc
func start_tweens(random_arr_indices: PackedByteArray):
	world.start_cards_tween(random_arr_indices)
	
@rpc("any_peer")
func on_intro_done_server(id: int):
	if not multiplayer.is_server(): return
	
	peers_intro_done.append(id)
	if len(peers_intro_done) == 2:
		
		var arr = range(25) # 25 is length of cards in deck
		arr.shuffle()
		var packed = PackedByteArray(arr)
		
		start_tweens.rpc(packed)
	
func on_intro_done():
	on_intro_done_server.rpc(my_id)
	
@rpc("any_peer")
func on_start_cards_tween_done_server(id: int):
	if not multiplayer.is_server(): return
	
	peers_start_cards_tween_done.append(id)
	if len(peers_start_cards_tween_done) == 2:
		print("[1] Setting game status is now IN_PROGRESS")
		GlobalServer.update_game_status.rpc(GlobalServer.GAME_STATUS.IN_PROGRESS)
		GlobalServer.update_player_turn.rpc(GlobalServer.PLAYER.ONE)
		
func on_start_cards_tween_done():
	on_start_cards_tween_done_server.rpc(my_id)

func on_peer_connected_to_server(id: int) -> void:
	print("[1] peer '%s' connected" % id)
	peers.append(id)
	print("[1] peers ", peers)
	
	if len(peers) == 2:
		create_world.rpc(peers[0], peers[1])

func on_peer_disconnected_to_server(id: int) -> void:
	print("[1] peer '%s' disconnected" % id)
	peers.erase(id)
	print("[1] peers ", peers)
	
func on_peer_connected(id: int) -> void:
	print("[%s] peer '%s' connected" % [my_id , id])

func on_peer_disconnected(id: int) -> void:
	print("[%s] peer '%s' disconnected" % [my_id, id])
	
func on_connected_to_server() -> void:
	print("[%s] on_connected_to_server called" % my_id)
	main_menu_ui.update_status_label("Connected to server. Waiting for other player...")
	
func on_connection_failed() -> void:
	print("[%s] on_connection_failed called" % my_id)
	main_menu_ui.update_status_label("Failed to connect to server")
	main_menu_ui.enable_join_btn()
	
func on_server_disconnected() -> void:
	print("[%s] on_server_disconnected called" % my_id)
