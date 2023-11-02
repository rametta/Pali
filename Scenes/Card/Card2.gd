extends Area3D

signal select()

@export var plane_mesh = MeshInstance3D
@export var outline_mesh: MeshInstance3D
@export var card_mesh: MeshInstance3D
@export var attack_mesh: MeshInstance3D
@export var title_mesh: MeshInstance3D
@export var card_color: Color
@export var card_texture: Texture2D

@export var attack: int
@export var title: String

var is_hovering = false

func _ready():
	card_mesh.material_override.albedo_color = card_color
	plane_mesh.material_override.albedo_texture = card_texture
	attack_mesh.mesh.text = str(attack)
	attack_mesh.mesh.material.albedo_color = card_color
	title_mesh.mesh.text = title
	render_outline()

func _on_mouse_entered():
	is_hovering = true
	render_outline()

func _on_mouse_exited():
	is_hovering = false
	render_outline()

func _on_input_event(_camera, event: InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select.emit()
			
func render_outline() -> void:
	if is_hovering or Global.selected_card_id == get_instance_id():
		outline_mesh.show()
	else:
		outline_mesh.hide()
