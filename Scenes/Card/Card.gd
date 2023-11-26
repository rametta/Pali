extends Area3D

signal select()

@export var plane_mesh = MeshInstance3D
@export var outline_mesh: MeshInstance3D
@export var card_mesh: MeshInstance3D
@export var card_resource: CardResource

var zone: Global.CARD_ZONE = Global.CARD_ZONE.DECK

func _ready():
	card_mesh.material_override.albedo_color = card_resource.color
	plane_mesh.material_override.albedo_texture = card_resource.texture
	render_outline()

func _on_input_event(_camera, event: InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select.emit()
			
func render_outline() -> void:
	if Global.selected_card_name == name:
		outline_mesh.show()
	else:
		outline_mesh.hide()
