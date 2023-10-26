extends Node3D

@export var cards: Node3D
@export var cards_position_x_curve: Curve ## left/right position on table

func _ready():
	cards.hide()

func start_cards_tween():
	cards.show()
	for card_id in range(cards.get_child_count()):
		var offset = float(card_id) / float(cards.get_child_count() - 1)
		var pos_x = cards_position_x_curve.sample(offset)
		
		var card: Node3D = cards.get_child(card_id)
		card.position = Vector3(0, 0, 0)
		card.rotation_degrees = Vector3(0, 0, 180)
		
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position:x", pos_x, 1)
		tween.tween_property(card, "rotation_degrees:z", 0, 1)
