extends Area3D

signal select()

@export var outline: MeshInstance3D
@export var player_a_cards: Node3D
@export var player_b_cards: Node3D
@export var connectors: Array[Node3D]

func _ready():
	outline.hide()

func _on_mouse_entered():
	outline.show()

func _on_mouse_exited():
	outline.hide()

func _on_input_event(_camera, event: InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select.emit()

func add_card(player_kind: Global.PlayerKind, card: Node3D, pos: Vector3, rot: Vector3) -> bool:
	match player_kind:
		Global.PlayerKind.PLAYER_A:
			player_a_cards.add_child(card)
			card.global_position = pos
			card.global_rotation = rot
			card.is_selected = false
			card.render_outline()
			return true
		Global.PlayerKind.PLAYER_B:
			player_b_cards.add_child(card)
			card.global_position = pos
			card.global_rotation = rot
			card.is_selected = false
			card.render_outline()
			return true
		_:
			return false

func has_player_a_card() -> bool:
	return player_a_cards.get_child_count() > 0
	
func has_player_b_card() -> bool:
	return player_b_cards.get_child_count() > 0
