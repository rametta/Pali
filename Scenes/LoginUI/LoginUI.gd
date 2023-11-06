extends Control

signal back_pressed()

func _on_back_btn_pressed():
	back_pressed.emit()

func _on_login_btn_pressed():
	pass # Replace with function body.
