extends Node3D

@export var cards: Node3D
@export var cards_position_z_curve: Curve ## left/right position on table
@export var cards_position_y_curve: Curve ## Overlap, middle highest
@export var cards_position_x_curve: Curve ## Height on table, middle tallest
@export var cards_rotation_y_curve: Curve

@export var zone_a: Marker3D

func _ready():
	cards.hide()

func start_cards_tween():
	cards.show()
	for card_id in range(cards.get_child_count()):
		var offset = float(card_id) / float(cards.get_child_count() - 1)
		var pos_x = cards_position_x_curve.sample(offset)
		var pos_y = cards_position_y_curve.sample(offset)
		var pos_z = cards_position_z_curve.sample(offset)
		var rot_y = cards_rotation_y_curve.sample(offset)
		
		var card: Node3D = cards.get_child(card_id)
		card.position = Vector3(0.6, 1, 0)
		card.rotation_degrees = Vector3(0, 90, 180)
		card.rest_position_y = pos_y
		
		card.connect("click", _move_card.bind(card))
		
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "position", Vector3(pos_x, pos_y, pos_z), 1)
		tween.tween_property(card, "rotation_degrees", Vector3(0, rot_y, 0), 1)

func _move_card(card: Node3D):
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "global_position", zone_a.global_position, .5)
	tween.tween_property(card, "rotation_degrees", Vector3.ZERO, .5)

