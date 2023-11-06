extends Control

signal create_account_pressed()
signal login_pressed()

func _on_create_account_btn_pressed():
	create_account_pressed.emit()


func _on_login_btn_pressed():
	login_pressed.emit()
