extends Control

signal join_server_pressed(display_name: String)
signal create_server_pressed()

@export var name_input: LineEdit
@export var join_btn: Button
@export var status_label: Label

func _ready():
	_on_name_input_text_changed(name_input.text)

func _on_join_server_btn_pressed():
	join_server_pressed.emit(name_input.text)
	disable_join_btn()

func _on_name_input_text_changed(new_text):
	if len(new_text) > 2:
		enable_join_btn()
	else:
		disable_join_btn()

func _on_create_server_btn_pressed():
	create_server_pressed.emit()

func update_status_label(text: String) -> void:
	status_label.text = text

func enable_join_btn() -> void:
	join_btn.disabled = false
	
func disable_join_btn() -> void:
	join_btn.disabled = true
