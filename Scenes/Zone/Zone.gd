extends Area3D

@export var outline: MeshInstance3D
@export var player_a_cards: Node3D
@export var player_b_cards: Node3D

var selected = false

func _ready():
	outline.hide()

func _on_mouse_entered():
	outline.show()

func _on_mouse_exited():
	if not selected:
		outline.hide()

func _on_input_event(_camera, event: InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected = !selected
			render_outline()

func render_outline() -> void:
	if selected:
		outline.show()
	else:
		outline.hide()

func add_card(player_kind: Global.PlayerKind, card: Node3D) -> bool:
	match player_kind:
		Global.PlayerKind.PLAYER_A:
			player_a_cards.add_child(card)
			return true
		Global.PlayerKind.PLAYER_B:
			player_b_cards.add_child(card)
			return true
		_:
			return false
