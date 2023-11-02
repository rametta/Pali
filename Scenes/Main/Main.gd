extends Node3D

@export var camera: Camera3D
@export var hand: Node3D
@export var cards_position_x_curve: Curve ## left/right position on table
@export var start_game_timer: Timer
@export var hud: Control
@export var table_cards: Node3D
@export var deck: Node3D

const CAMERA_PARRALAX_SENSITIVITY: int = 200 ## Higher is slower

const game_time_sec_default = 3 * 60
var game_time_sec = game_time_sec_default

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	hud.hide()
	hand.hide()
	hud.update_game_time(game_time_sec)
	
	for card in deck.get_children():
		card.connect("select", on_card_select.bind(card))

func _input(event):
	if game_time_sec == game_time_sec_default:
		return
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

func start_cards_tween():
	hand.show()
	for card_id in range(hand.get_child_count()):
		var offset = float(card_id) / float(hand.get_child_count() - 1)
		var pos_x = cards_position_x_curve.sample(offset)
		
		var card: Node3D = hand.get_child(card_id)
		card.position = Vector3(0, card_id * .01, card_id * .01)
		card.rotation_degrees = Vector3(0, 0, 180)
		
		card.connect("select", on_card_select.bind(card))
		
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position:x", pos_x, .75)
		tween.tween_property(card, "rotation_degrees:z", 0, .75)
		tween.tween_callback(
			func():
				start_game_timer.start()
				hud.show()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		)
		tween.parallel().tween_property(card, "position:y", 0, .25)
		tween.parallel().tween_property(card, "position:z", 0, .25)

func on_card_select(card: Node3D) -> void:
	Global.selected_card_id = card.get_instance_id()
	get_tree().call_group("card", "render_outline")

func on_table_select(table_pos: Vector3) -> void:
	var new_table_pos = table_pos
	new_table_pos.y += .06
	
	var card: Node3D = instance_from_id(Global.selected_card_id)
	if not card:
		return
		
	var is_already_on_table = card.is_in_group("card_on_table")
		
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "global_rotation:x", 0, .5)
	tween.parallel().tween_property(card, "global_position", new_table_pos, .5).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		card.is_hovering = false
		Global.selected_card_id = null
		get_tree().call_group("card", "render_outline")
		
		if is_already_on_table:
			render_hand()
		else:
			var pos = card.global_position
			var rot = card.global_rotation
			var parent = card.get_parent()
			parent.remove_child(card)
			table_cards.add_child(card)
			card.global_position = pos
			card.global_rotation = rot
			card.add_to_group("card_on_table")
			add_card_to_hand()
	)

func add_card_to_hand() -> void:
	if deck.get_child_count() == 0:
		return
		
	var deck_top_card = deck.get_child(0)
	var old_pos = deck_top_card.global_position
	var old_rot = deck_top_card.global_rotation
	deck.remove_child(deck_top_card)
	hand.add_child(deck_top_card)
	deck_top_card.global_position = old_pos
	deck_top_card.global_rotation = old_rot
	render_hand()

func render_hand() -> void:
	var count = hand.get_child_count()
	var dividend = count - 1
	
	for card_id in range(count):
		var offset = 0.5
		
		if dividend > 0:
			offset = float(card_id) / float(dividend)
		
		var pos_x = cards_position_x_curve.sample(offset)
		var card = hand.get_child(card_id)
		var pos = Vector3(pos_x, 0, 0)
		var rot = Vector3.ZERO
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(card, "position", pos, .35)
		tween.parallel().tween_property(card, "rotation", rot, .35)


func _on_start_game_timer_timeout():
	game_time_sec -= 1
	hud.update_game_time(game_time_sec)
	
	if game_time_sec <= 0:
		start_game_timer.stop()
		print("game over - show winner here")


func _on_table_zone_input_event(_camera: Node, event: InputEvent, pos: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton and Global.selected_card_id:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_table_select(pos)

