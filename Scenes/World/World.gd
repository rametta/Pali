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
const SAME_CATEGORY_POINTS: int = 2
const SAME_TAG_POINTS: int = 1

const dropzone_scene = preload("res://Scenes/Dropzone/Dropzone.tscn")

@export var camera: Camera3D
@export var top_camera: Camera3D
@export var my_hand: Node3D
@export var opponent_hand: Node3D
@export var cards_position_x_curve: Curve ## left/right position on table
@export var hud: Control
@export var table_cards: Node3D
@export var dropzones: Node3D
@export var deck: Node3D
@export var card_player: AudioStreamPlayer
@export var card_player_2: AudioStreamPlayer
@export var switch_cards_dialog: ConfirmationDialog

var player_1_hand: Node3D ## either my_hand or opponent_hand
var player_2_hand: Node3D ## either my_hand or opponent_hand

var player: PLAYER = PLAYER.SERVER ## Set when world is created by the server
var player_1_id: int
var player_2_id: int

var is_rendering_hand_animating = false
var is_table_select_animating = false

## Var prepended with "synced" are available on
## all clients
var synced_game_status: GAME_STATUS = GAME_STATUS.PRE_GAME
var synced_player_turn: PLAYER = PLAYER.ONE
var synced_peer_name_map: Dictionary = {}

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
func intro_done_server() -> void:
	if not multiplayer.is_server(): return
	
	var id = multiplayer.get_remote_sender_id()
	server_peers_intro_done.append(id)
	if len(server_peers_intro_done) == 2:
		
		var arr = range(25) # 25 is length of cards in deck
		arr.shuffle()
		var packed = PackedByteArray(arr)
		
		start_cards_tween.rpc(packed)
		
@rpc("any_peer")
func start_cards_tween_done_server():
	if not multiplayer.is_server(): return
	
	var id = multiplayer.get_remote_sender_id()
	server_peers_start_cards_tween_done.append(id)
	if len(server_peers_start_cards_tween_done) == 2:
		print("[1] Setting game status is now IN_PROGRESS")
		update_game_status.rpc(GAME_STATUS.IN_PROGRESS)
		update_player_turn.rpc(PLAYER.ONE)
		recalculate_scores_server()
		
@rpc("any_peer")
func card_played_server() -> void:
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
	switch_cards_dialog.hide()
	
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
		
	create_dropzones()
	
func create_dropzones() -> void:
	for i in range(3):
		for j in range(7):
			var dropzone = dropzone_scene.instantiate()
			dropzone.position = Vector3(-0.608 + (.584 * float(i)), 0, 1.313 - (.43 * float(j)))
			dropzone.input_event.connect(on_dropzone_input_event.bind(dropzone))
			dropzone.name = &"dz-%d-%d" % [i, j]
			dropzones.add_child(dropzone)

func on_dropzone_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape: int, dropzone: Area3D) -> void:
	if event is InputEventMouseButton\
		and event.button_index == MOUSE_BUTTON_LEFT\
		and event.pressed\
		and synced_player_turn == player\
		and not is_rendering_hand_animating\
		and not is_table_select_animating:
			if Global.selected_hand_card_name and not Global.selected_table_card_name:
				play_card_server.rpc_id(1, dropzone.name, Global.selected_hand_card_name)
	
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
	if multiplayer.is_server(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	intro_done_server.rpc_id(1)

@rpc("call_local")
func start_cards_tween(random_arr_indices: PackedByteArray) -> void:
	deck.deck_init(random_arr_indices)
	for card in deck.get_children():
		card.select.connect(on_card_select.bind(card))
	
	await start_hand_tweens(player_1_hand, Global.CARD_ZONE.PLAYER_1_HAND)
	await start_hand_tweens(player_2_hand, Global.CARD_ZONE.PLAYER_2_HAND)
	
	if not multiplayer.is_server():
		hud.update_player_1_label(synced_peer_name_map[player_1_id], 0)
		hud.update_player_2_label(synced_peer_name_map[player_2_id], 0)
		hud.show()
		start_cards_tween_done_server.rpc_id(1)

func start_hand_tweens(hand: Node3D, zone: Global.CARD_ZONE) -> void:
	hand.show()
	for i in range(5):
		var card = deck.get_child(deck.get_child_count() - 1)
		
		switch_parents(card, hand)
		card.zone = zone
		
		var offset = float(i) / 4.0
		var pos_x = cards_position_x_curve.sample(offset)
		var poss = Vector3(pos_x, 0, 0)
		var rott = Vector3.ZERO
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", poss, .2)
		tween.parallel().tween_property(card, "rotation", rott, .2)
		card_player_2.play()
		await tween.finished

func _on_switch_cards_dialog_canceled():
	Global.selected_table_card_name = ""
	refresh_outlines()

func _on_switch_cards_dialog_confirmed():
	switch_card_server.rpc_id(1, Global.selected_table_card_name, Global.selected_hand_card_name)
	
func show_dialog() -> void:
	var hand_card = my_hand.find_child(Global.selected_hand_card_name, true, false)
	var table_card = table_cards.find_child(Global.selected_table_card_name, true, false)
	switch_cards_dialog.dialog_text = "Are you sure you would like to switch '%s' with '%s'?" % [hand_card.card_resource.title, table_card.card_resource.title]
	switch_cards_dialog.show()

func on_card_select(card: Node3D) -> void:
	if card.zone == Global.CARD_ZONE.DECK:
		return
		
	if player == PLAYER.ONE and card.zone == Global.CARD_ZONE.PLAYER_2_HAND:
		return
		
	if player == PLAYER.TWO and card.zone == Global.CARD_ZONE.PLAYER_1_HAND:
		return
		
	if card.zone == Global.CARD_ZONE.TABLE:
		Global.selected_table_card_name = card.name
	else:
		Global.selected_hand_card_name = card.name
		
	if Global.selected_table_card_name and Global.selected_hand_card_name:
		show_dialog()
		
	refresh_outlines()
	
func refresh_outlines() -> void:
	get_tree().call_group("card", "render_outline")
	
@rpc("call_local")
func play_card_client(dz_name: StringName, card_name: String) -> void:
	var dz = dropzones.find_child(dz_name, true, false)
	if not dz:
		return
	
	var card = find_child(card_name, true, false)
	if not card:
		return
		
	dz.input_ray_pickable = false
		
	var old_zone = card.zone
	is_table_select_animating = true

	switch_parents(card, table_cards)
	card.zone = Global.CARD_ZONE.TABLE

	Global.selected_hand_card_name = ""
	Global.selected_table_card_name = ""
	refresh_outlines()

	card_player.play()
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_rotation_degrees", Vector3(0, 90, 0), .5)
	tween.parallel().tween_property(card, "global_position", dz.global_position, .5).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	is_table_select_animating = false

	if old_zone == Global.CARD_ZONE.PLAYER_1_HAND:
		add_card_to_hand(player_1_hand, old_zone)
		render_hand(player_1_hand)
	elif old_zone == Global.CARD_ZONE.PLAYER_2_HAND:
		add_card_to_hand(player_2_hand, old_zone)
		render_hand(player_2_hand)
			
	if multiplayer.is_server():
		recalculate_scores_server()
		card_played_server()
	
func switch_parents(node, new_parent) -> void:
	var pos = node.global_position
	var rot = node.global_rotation
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	node.global_position = pos
	node.global_rotation = rot
	
@rpc("call_local")
func switch_card_client(table_card_name: String, hand_card_name: String) -> void:
	var table_card = find_child(table_card_name, true, false)
	if not table_card:
		return
		
	var hand_card = find_child(hand_card_name, true, false)
	if not hand_card:
		return
		
	var hand = player_1_hand
	var zone = Global.CARD_ZONE.PLAYER_1_HAND
	if synced_player_turn == PLAYER.TWO:
		hand = player_2_hand
		zone = Global.CARD_ZONE.PLAYER_2_HAND
		
	switch_parents(hand_card, table_cards)
	hand_card.zone = Global.CARD_ZONE.TABLE
	
	switch_parents(table_card, hand)
	table_card.zone = zone

	card_player.play()
	var tween = get_tree().create_tween()
	tween.tween_property(hand_card, "global_rotation_degrees", Vector3(0, 90, 0), .5)
	tween.parallel().tween_property(hand_card, "global_position", table_card.global_position, .5).set_trans(Tween.TRANS_QUAD)

	if synced_player_turn == PLAYER.ONE:
		render_hand(player_1_hand)
	elif synced_player_turn == PLAYER.TWO:
		render_hand(player_2_hand)
		
	Global.selected_hand_card_name = ""
	Global.selected_table_card_name = ""
	refresh_outlines()
		
	if multiplayer.is_server():
		recalculate_scores_server()
		card_played_server()
	

@rpc("any_peer")
func play_card_server(dz_name: StringName, card_name: String) -> void:
	if not multiplayer.is_server(): return
	
	var id = multiplayer.get_remote_sender_id()
	if synced_player_turn == PLAYER.ONE and id != player_1_id:
		print("[1] Card can not be played on table. Not correct player turn. Player turn is 1. 2 is trying to play but shouldn't")
		return
		
	if synced_player_turn == PLAYER.TWO and id != player_2_id:
		print("[1] Card can not be played on table. Not correct player turn. Player turn is 2. 1 is trying to play but shouldn't")
		return
	
	var dz = dropzones.find_child(dz_name, true, false)
	if not dz:
		print("[1] Card can not be played on table. Dropzone can not be found")
		return
	
	var card = find_child(card_name, true, false)
	if not card:
		print("[1] Card can not be played on table. Card can not be found")
		return
		
	if card.zone == Global.CARD_ZONE.TABLE or card.zone == Global.CARD_ZONE.DECK:
		print("[1] Card can not be played on table. Card zone is already TABLE or DECK. Card must be played from a hand")
		return
		
	play_card_client.rpc(dz_name, card_name)
	
@rpc("any_peer")
func switch_card_server(table_card_name: String, hand_card_name: String) -> void:
	if not multiplayer.is_server(): return
	
	var id = multiplayer.get_remote_sender_id()
	if synced_player_turn == PLAYER.ONE and id != player_1_id:
		print("[1] Card can not be switched on table. Not correct player turn. Player turn is 1. 2 is trying to play but shouldn't")
		return
		
	if synced_player_turn == PLAYER.TWO and id != player_2_id:
		print("[1] Card can not be switched on table. Not correct player turn. Player turn is 2. 1 is trying to play but shouldn't")
		return
	
	var table_card = find_child(table_card_name, true, false)
	if not table_card:
		print("[1] Card can not be switched on table. Table card can not be found")
		return
		
	var hand_card = find_child(hand_card_name, true, false)
	if not hand_card:
		print("[1] Card can not be switched on table. Hand card can not be found")
		return
	
	switch_card_client.rpc(table_card_name, hand_card_name)

@rpc
func update_scores(p1_score: int, p2_score: int) -> void:
	hud.update_player_1_label(synced_peer_name_map[player_1_id], p1_score)
	hud.update_player_2_label(synced_peer_name_map[player_2_id], p2_score)

@rpc("any_peer")
func recalculate_scores_server() -> void:
	if not multiplayer.is_server(): return
	var p1_score = get_hand_score(player_1_hand)
	var p2_score = get_hand_score(player_2_hand)
	update_scores.rpc(p1_score, p2_score)

func get_hand_score(hand: Node3D) -> int:
	var resources = hand.get_children().map(func (child): return child.card_resource)
	var score = 0
	
	for card in resources:
		score += card.value
		for c in resources:
			if c.id == card.id:
				continue
				
			if c.category == card.category:
				score += SAME_CATEGORY_POINTS
				
			for tag in card.tags:
				if tag in c.tags:
					score += SAME_TAG_POINTS
					
			for relation in card.relations:
				if relation.card_id == c.id:
					score += relation.value
					
	return score

func add_card_to_hand(hand: Node3D, zone: Global.CARD_ZONE) -> void:
	if deck.get_child_count() == 0:
		if multiplayer.is_server():
			print("the game is over! calculate the winner, show winner, then disconnect everyone")
			# TODO: game over logic
		return
		
	var card = deck.get_child(deck.get_child_count() - 1)
	switch_parents(card, hand)
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
