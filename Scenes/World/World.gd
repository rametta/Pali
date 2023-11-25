extends Node3D

enum GAME_STATUS {
	PRE_GAME,
	IN_PROGRESS,
	POST_GAME
}

enum PLAYER {
	ONE,
	TWO,
	SERVER
}

const CAMERA_PARRALAX_SENSITIVITY: int = 200 ## Higher is slower

@export var camera: Camera3D
@export var top_camera: Camera3D
@export var my_hand: Node3D
@export var opponent_hand: Node3D
@export var cards_position_x_curve: Curve ## left/right position on table
@export var hud: Control
@export var table_cards: Node3D
@export var deck: Node3D

var player_1_hand: Node3D ## either my_hand or opponent_hand
var player_2_hand: Node3D ## either my_hand or opponent_hand

var player: PLAYER = PLAYER.SERVER ## Set when world is created by the server

var is_rendering_hand_animating = false
var is_table_select_animating = false

## Var prepended with "synced" are available on
## all clients
var synced_game_status: GAME_STATUS = GAME_STATUS.PRE_GAME
var synced_player_turn: PLAYER = PLAYER.ONE

## Vars prepended with "server" are only available
## on the server
var server_peers_intro_done: Array[int] = []
var server_peers_start_cards_tween_done: Array[int] = []

@rpc("call_local")
func update_game_status(gs: GAME_STATUS) -> void:
	synced_game_status = gs
	
@rpc("call_local")
func update_player_turn(p: PLAYER) -> void:
	synced_player_turn = p
	hud.update_title(player == p)
	
@rpc("any_peer")
func intro_done() -> void:
	if not multiplayer.is_server(): return
	
	var id = multiplayer.get_remote_sender_id()
	server_peers_intro_done.append(id)
	if len(server_peers_intro_done) == 2:
		
		var arr = range(25) # 25 is length of cards in deck
		arr.shuffle()
		var packed = PackedByteArray(arr)
		
		start_cards_tween.rpc(packed)
		
@rpc("any_peer")
func start_cards_tween_done():
	if not multiplayer.is_server(): return
	
	var id = multiplayer.get_remote_sender_id()
	server_peers_start_cards_tween_done.append(id)
	if len(server_peers_start_cards_tween_done) == 2:
		print("[1] Setting game status is now IN_PROGRESS")
		update_game_status.rpc(GAME_STATUS.IN_PROGRESS)
		update_player_turn.rpc(PLAYER.ONE)
		
@rpc("any_peer")
func card_played() -> void:
	if not multiplayer.is_server(): return
	
	if synced_player_turn == PLAYER.ONE:
		update_player_turn.rpc(PLAYER.TWO)
	elif synced_player_turn == PLAYER.TWO:
		update_player_turn.rpc(PLAYER.ONE)
		
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	hud.hide()
	my_hand.hide()
	opponent_hand.hide()
	
	if player == PLAYER.ONE:
		player_1_hand = my_hand
		player_2_hand = opponent_hand
	elif player == PLAYER.TWO:
		player_2_hand = my_hand
		player_1_hand = opponent_hand
	elif player == PLAYER.SERVER:
		player_1_hand = my_hand
		player_2_hand = opponent_hand
		top_camera.current = true
		camera.current = false

func _input(event):
	if synced_game_status != GAME_STATUS.IN_PROGRESS:
		return

	if event.is_action_pressed("zoom"):
		if top_camera.current:
			top_camera.current = false
			camera.current = true
		else:
			top_camera.current = true
			camera.current = false
		
	# Slightly rotate camera to get nice "parralax" effect
	if event is InputEventMouseMotion:
		var screen_size = get_viewport().get_visible_rect().size
		
		var rot_y = 90
		var rot_x = -37
		
		var screen_width = screen_size.x
		var half_screen_width = screen_width / 2
		if event.position.x >= half_screen_width:
			rot_y -= ((event.position.x - half_screen_width) / CAMERA_PARRALAX_SENSITIVITY)
		else:
			rot_y += ((half_screen_width - event.position.x) / CAMERA_PARRALAX_SENSITIVITY)
			
		var screen_height = screen_size.y
		var half_screen_height = screen_height / 2
		if event.position.y >= half_screen_height:
			rot_x -= ((event.position.y - half_screen_height) / CAMERA_PARRALAX_SENSITIVITY)
		else:
			rot_x += ((half_screen_height - event.position.y) / CAMERA_PARRALAX_SENSITIVITY)

		var t = get_tree().create_tween()
		t.tween_property(camera, "rotation_degrees", Vector3(rot_x, rot_y, camera.rotation_degrees.z), .5)

func intro_anim_done() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	intro_done.rpc()

@rpc("call_local")
func start_cards_tween(random_arr_indices: PackedByteArray) -> void:
	deck.deck_init(random_arr_indices)
	for card in deck.get_children():
		card.select.connect(on_card_select.bind(card))
	
	await start_hand_tweens(player_1_hand, Global.CARD_ZONE.PLAYER_1_HAND)
	await start_hand_tweens(player_2_hand, Global.CARD_ZONE.PLAYER_2_HAND)
	
	if not multiplayer.is_server():
		hud.show()
		start_cards_tween_done.rpc()

func start_hand_tweens(hand: Node3D, zone: Global.CARD_ZONE) -> void:
	hand.show()
	for i in range(5):
		var card = deck.get_child(deck.get_child_count() - 1)
		
		var pos = card.global_position
		var rot = card.global_rotation
		deck.remove_child(card)
		hand.add_child(card)
		card.global_position = pos
		card.global_rotation = rot
		card.zone = zone
		
		var offset = float(i) / 4.0
		var pos_x = cards_position_x_curve.sample(offset)
		var poss = Vector3(pos_x, 0, 0)
		var rott = Vector3.ZERO
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", poss, .2)
		tween.parallel().tween_property(card, "rotation", rott, .2)
		await tween.finished

func on_card_select(card: Node3D) -> void:
	if player == PLAYER.ONE and card.zone != Global.CARD_ZONE.PLAYER_1_HAND:
		return
		
	if player == PLAYER.TWO and card.zone != Global.CARD_ZONE.PLAYER_2_HAND:
		return
		
	Global.selected_card_name = card.name
	get_tree().call_group("card", "render_outline")

@rpc("call_local", "any_peer")
func on_table_select(table_pos: Vector3, card_name: String) -> void:
	## TODO: add server validation here
	if is_rendering_hand_animating || is_table_select_animating:
		print("is_rendering_hand_animating or is_table_select_animating is true. can not select table")
		return
		
	var new_table_pos = table_pos
	new_table_pos.y += .06
	
	var card: Node3D = find_child(card_name, true, false)
	if not card:
		return
		
	var old_zone = card.zone
	is_table_select_animating = true
	var is_already_on_table = card.zone == Global.CARD_ZONE.TABLE
	if not is_already_on_table:
		var pos = card.global_position
		var rot = card.global_rotation
		var parent = card.get_parent()
		parent.remove_child(card)
		table_cards.add_child(card)
		card.global_position = pos
		card.global_rotation = rot
		card.zone = Global.CARD_ZONE.TABLE

	card.is_hovering = false
	Global.selected_card_name = ""
	get_tree().call_group("card", "render_outline")

	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_rotation_degrees", Vector3(0, 90, 0), .5)
	tween.parallel().tween_property(card, "global_position", new_table_pos, .5).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	is_table_select_animating = false

	if not is_already_on_table:
		if old_zone == Global.CARD_ZONE.PLAYER_1_HAND:
			add_card_to_hand(player_1_hand, old_zone)
			render_hand(player_1_hand)
		elif old_zone == Global.CARD_ZONE.PLAYER_2_HAND:
			add_card_to_hand(player_2_hand, old_zone)
			render_hand(player_2_hand)

func add_card_to_hand(hand: Node3D, zone: Global.CARD_ZONE) -> void:
	if deck.get_child_count() == 0:
		return
		
	var card = deck.get_child(deck.get_child_count() - 1)
	var old_pos = card.global_position
	var old_rot = card.global_rotation
	deck.remove_child(card)
	hand.add_child(card)
	card.global_position = old_pos
	card.global_rotation = old_rot
	card.zone = zone

func render_hand(hand: Node3D) -> void:
	var count = hand.get_child_count()
	var dividend = count - 1
	
	var parallel = Parallel.new()

	is_rendering_hand_animating = true
	for card_id in range(count):
		var offset = 0.5
		
		if dividend > 0:
			offset = float(card_id) / float(dividend)
		
		var pos_x = cards_position_x_curve.sample(offset)
		var card = hand.get_child(card_id)
		var pos = Vector3(pos_x, 0, 0)
		var rot = Vector3.ZERO
		var awaitable = func():
			var tween = get_tree().create_tween()
			tween.tween_property(card, "position", pos, 1)
			tween.parallel().tween_property(card, "rotation", rot, 1)
			await tween.finished
		parallel.add_awaitable(awaitable)

	parallel.done.connect(func(): is_rendering_hand_animating = false)
	parallel.start()
		
func _on_table_zone_input_event(_camera: Node, event: InputEvent, pos: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton\
		and event.button_index == MOUSE_BUTTON_LEFT\
		and event.pressed\
		and synced_player_turn == player\
		and Global.selected_card_name:
			card_played.rpc()
			on_table_select.rpc(pos, Global.selected_card_name)
