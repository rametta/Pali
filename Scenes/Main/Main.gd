extends Node3D

@export var camera: Camera3D
@export var cards: Node3D
@export var cards_position_x_curve: Curve ## left/right position on table
#@export var zones: Node3D
#@export var connectors: Node3D
@export var start_game_timer: Timer
@export var hud: Control
@export var table_cards: Node3D

const CAMERA_PARRALAX_SENSITIVITY: int = 200 ## Higher is slower

var selected_card_id = null

const game_time_sec_default = 3 * 60
var game_time_sec = game_time_sec_default

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	hud.hide()
	cards.hide()
	hud.update_game_time(game_time_sec)
	
#	for zone in zones.get_children():
#		zone.connect('select', on_zone_select.bind(zone))
#
#	for connector in connectors.get_children():
#		connector.hide()

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
	cards.show()
	for card_id in range(cards.get_child_count()):
		var offset = float(card_id) / float(cards.get_child_count() - 1)
		var pos_x = cards_position_x_curve.sample(offset)
		
		var card: Node3D = cards.get_child(card_id)
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
	selected_card_id = card.get_instance_id()
	get_tree().call_group("player_a_cards", "set_and_render_outline", selected_card_id)

func on_table_select(table_pos: Vector3) -> void:
	var card: Node3D = instance_from_id(selected_card_id)
	if card:
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(card, "global_rotation:x", 0, .5)
		tween.parallel().tween_property(card, "global_position", table_pos, .5).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(func():
			var pos = card.global_position
			var rot = card.global_rotation
			var parent = card.get_parent()
			parent.remove_child(card)
			table_cards.add_child(card)
			card.global_position = pos
			card.global_rotation = rot
			card.position.y = .06
			selected_card_id = null
		)
		tween.tween_interval(.1)
		tween.tween_callback(render_hand)

func render_hand() -> void:
	var count = cards.get_child_count()
	var dividend = count - 1
	
	for card_id in range(count):
		var offset = 0.5
		
		if dividend > 0:
			offset = float(card_id) / float(dividend)
		
		var pos_x = cards_position_x_curve.sample(offset)
		var card = cards.get_child(card_id)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position:x", pos_x, .35)


func _on_start_game_timer_timeout():
	game_time_sec -= 1
	hud.update_game_time(game_time_sec)
	
	if game_time_sec <= 0:
		start_game_timer.stop()
		print("game over - show winner here")


func _on_table_zone_input_event(_camera: Node, event: InputEvent, pos: Vector3, _normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton and selected_card_id:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_table_select(pos)

