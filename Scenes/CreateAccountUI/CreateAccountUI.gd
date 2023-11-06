extends Control

signal back_pressed()

@onready var username_input: LineEdit = $MarginContainer/VBoxContainer/VBoxContainer/UsernameInput
@onready var email_input: LineEdit = $MarginContainer/VBoxContainer/VBoxContainer/EmailInput
@onready var password_input: LineEdit = $MarginContainer/VBoxContainer/VBoxContainer/PasswordInput


func _on_back_btn_pressed():
	back_pressed.emit()


func _on_create_btn_pressed():
	pass # Replace with function body.
