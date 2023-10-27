extends Area3D

signal select()

@onready var outline: MeshInstance3D = %OutlineMesh
@onready var text_mesh: MeshInstance3D = %TextMesh

@export var cost: int
@export var attack: int
@export var shield: int

var is_hovering = false
var is_selected = false

func _ready():
	text_mesh.mesh.text = "Cost: %s\nAttack: %s\nShield: %s" % [cost, attack, shield]
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
	if is_hovering or is_selected:
		outline.show()
	else:
		outline.hide()

func set_and_render_outline(selected_id: int) -> void:
	is_selected = selected_id == get_instance_id()
	render_outline()
