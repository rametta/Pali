extends Control

signal join_server_pressed(display_name: String)
signal create_server_pressed()

@export var name_input: LineEdit
@export var join_btn: Button

func _ready():
	_on_name_input_text_changed(name_input.text)

func _on_join_server_btn_pressed():
	join_server_pressed.emit(name_input.text)

func _on_name_input_text_changed(new_text):
	if len(new_text) > 2:
		join_btn.disabled = false
	else:
		join_btn.disabled = true

func _on_create_server_btn_pressed():
	create_server_pressed.emit()
