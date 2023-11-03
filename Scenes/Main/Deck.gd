extends Node3D

const card_scene = preload("res://Scenes/Card/Card2.tscn")
const sample_card_texture = preload("res://CardAssets/mycologist.png")

func deck_init() -> void:
	for i in range(25):
		var card = card_scene.instantiate()
		
		card.card_color = Color.AQUAMARINE
		card.title = "My Guy " + str(i)
		card.attack = 7
		card.card_texture = sample_card_texture
		card.zone = Global.CARD_ZONE.DECK
		
		add_child(card)
		card.rotation_degrees = Vector3(0, 90, -180)
		card.position.y = float(i) * .015
		
#		var tween = get_tree().create_tween()
#		tween.tween_interval(i * .15)
#		tween.tween_property(card, "position:y", i * .015, .15)
