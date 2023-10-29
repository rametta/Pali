extends MeshInstance3D


@export var zone_1: Node3D
@export var zone_2: Node3D

func render_visibility() -> void:
	if zone_1.has_player_a_card() and zone_2.has_player_a_card():
		show()
	else:
		hide()
