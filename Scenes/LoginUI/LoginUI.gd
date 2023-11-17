extends Control

signal back_pressed()
signal success_login()

@onready var login_btn: Button = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/LoginBtn
@onready var loading_label: Label = $MarginContainer/VBoxContainer/VBoxContainer/LoadingLabel
@onready var email_input: LineEdit = $MarginContainer/VBoxContainer/VBoxContainer/EmailInput
@onready var password_input: LineEdit = $MarginContainer/VBoxContainer/VBoxContainer/PasswordInput

func loading():
	loading_label.text = "Loading..."
	login_btn.disabled = true
	
func not_loading():
	loading_label.text = ""
	login_btn.disabled = false

func _on_password_input_text_submitted(_new_text):
	_on_login_btn_pressed()

func _on_back_btn_pressed():
	back_pressed.emit()

func _on_login_btn_pressed():
	pass

func _on_play_fab_client_api_error(api_error_wrapper):
	not_loading()
	print('_on_play_fab_client_api_error')
	print(api_error_wrapper)


func _on_play_fab_client_logged_in():
	pass

