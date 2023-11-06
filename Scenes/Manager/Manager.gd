extends Node

@onready var main_menu_ui: Control = $MainMenuUI
@onready var login_ui: Control = $LoginUI
@onready var create_account_ui: Control = $CreateAccountUI

func _ready() -> void:
	main_menu_ui.show()
	login_ui.hide()
	create_account_ui.hide()
	
	main_menu_ui.connect("create_account_pressed", main_menu_create_account_pressed)
	main_menu_ui.connect("login_pressed", main_menu_login_pressed)
	
	create_account_ui.connect("back_pressed", create_account_back_pressed)
	
	login_ui.connect("back_pressed", login_menu_back_pressed)
	
func main_menu_create_account_pressed() -> void:
	main_menu_ui.hide()
	login_ui.hide()
	create_account_ui.show()
	
func main_menu_login_pressed() -> void:
	main_menu_ui.hide()
	create_account_ui.hide()
	login_ui.show()

func create_account_back_pressed() -> void:
	create_account_ui.hide()
	login_ui.hide()
	main_menu_ui.show()

func login_menu_back_pressed() -> void:
	create_account_ui.hide()
	login_ui.hide()
	main_menu_ui.show()
