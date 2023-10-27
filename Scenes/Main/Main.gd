extends Node3D

@export var cards: Node3D
@export var cards_position_x_curve: Curve ## left/right position on table

@export var zones: Node3D

var selected_card_id = null

func _ready():
	cards.hide()
	
	for zone in zones.get_children():
		zone.connect('select', on_zone_select.bind(zone))

func start_cards_tween():
	cards.show()
	for card_id in range(cards.get_child_count()):
		var offset = float(card_id) / float(cards.get_child_count() - 1)
		var pos_x = cards_position_x_curve.sample(offset)
		
		var card: Node3D = cards.get_child(card_id)
		card.position = Vector3(0, 0, 0)
		card.rotation_degrees = Vector3(0, 0, 180)
		
		card.connect("select", on_card_select.bind(card))
		
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position:x", pos_x, 1)
		tween.tween_property(card, "rotation_degrees:z", 0, 1)

func on_card_select(card: Node3D) -> void:
	selected_card_id = card.get_instance_id()
	get_tree().call_group("player_a_cards", "set_and_render_outline", selected_card_id)
#	var all_cards = get_tree().get_nodes_in_group("player_a_cards")
#	for c in all_cards:
#		c.is_selected = selected_card_id == c.get_instance_id()
#		c.render_outline()

func on_zone_select(zone: Node3D) -> void:
	if selected_card_id:
		var card: Node3D = instance_from_id(selected_card_id)
		if card:
			var new_pos = zone.global_position
			new_pos.y += .1
			var tween = get_tree().create_tween()
			tween.parallel().tween_property(card, "global_position", new_pos, .5).set_ease(Tween.EASE_IN_OUT)
			tween.parallel().tween_property(card, "rotation_degrees:x", -54, .5)
			tween.tween_callback(func():
				var pos = card.global_position
				var rot = card.global_rotation
				var parent = card.get_parent()
				parent.remove_child(card)
				zone.add_card(Global.PlayerKind.PLAYER_A, card, pos, rot)
				selected_card_id = null
			)
			tween.tween_interval(.15)
			tween.tween_callback(render_hand)

func render_hand() -> void:
	var count = cards.get_child_count()
	var dividend = count - 1
	
	for card_id in range(count):
		var offset = 0.5
		
		if dividend > 0:
			offset = float(card_id) / float(dividend)
		
		var pos_x = cards_position_x_curve.sample(offset)
		var card: Node3D = cards.get_child(card_id)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position:x", pos_x, 1)
