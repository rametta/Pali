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
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", 0.1, .100).as_relative()
	outline.show()

func _on_mouse_exited():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", rest_position_y, .100)
	outline.hide()


func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event.is_action_pressed("click"):
		click.emit()
