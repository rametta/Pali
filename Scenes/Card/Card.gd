extends Area3D

signal click()

@onready var outline: MeshInstance3D = %Outline
@onready var text_mesh: MeshInstance3D = %TextMesh

@export var cost: int
@export var attack: int
@export var shield: int

var rest_position_y: float

func _ready():
	outline.hide()
	text_mesh.mesh.text = "Cost: %s\nAttack: %s\nShield: %s" % [cost, attack, shield]

func _on_mouse_entered():
	outline.show()

func _on_mouse_exited():
	outline.hide()

func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event.is_action_pressed("click"):
		click.emit()
