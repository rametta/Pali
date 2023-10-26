extends Area3D

@onready var outline: MeshInstance3D = %OutlineMesh
@onready var text_mesh: MeshInstance3D = %TextMesh

@export var cost: int
@export var attack: int
@export var shield: int

var selected = false

func _ready():
	outline.hide()
	text_mesh.mesh.text = "Cost: %s\nAttack: %s\nShield: %s" % [cost, attack, shield]

#func _process(_delta):
#	if dragging:
#		var mousepos = get_viewport().get_mouse_position()
#		print(mousepos, global_position)
##		global_position = Vector3(mousepos.x, global_position.y, mousepos.y)
#
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

func is_in_dropzone(area: Area3D) -> bool:
	return area.is_in_group("dropzone")

func card_dropped() -> void:
	var overlapping: Array[Area3D] = get_overlapping_areas().filter(is_in_dropzone)
	for area in overlapping:
		# Card is already in this dropzone, recenter it
		if area.get_instance_id() == GlobalState.card_in_dropzone(get_instance_id()):
			print("card is already in this dz. recentering")
			var tween = get_tree().create_tween()
			tween.tween_property(self, "global_position", area.global_position, 0.15)
			return
		
		# Dropzone is free, can drop card into it
		if GlobalState.is_dropzone_free(area.get_instance_id()):
			print("dropping card into this dz")
			
			var old_dz_id = GlobalState.card_in_dropzone(get_instance_id())
			if old_dz_id:
				print("freeing card from old dz")
				GlobalState.set_dropzone(old_dz_id, null)
			
			var tween = get_tree().create_tween()
			tween.tween_property(self, "global_position", area.global_position, 0.15)
			tween.tween_callback(
				func():
					GlobalState.set_dropzone(area.get_instance_id(), get_instance_id())
			)
			return
		else:
			print('dz is not free. can not drop card')
			
	# if we were in a dropzone previously and now we're not
	# then we release from the DZ and make it available globally
	var dz_id = GlobalState.card_in_dropzone(get_instance_id())
	if dz_id:
		print("freeing card from any dz")
		GlobalState.set_dropzone(dz_id, null)
		return
		
	print('no dz operation happened')
