extends Node

@onready var main_menu_ui: Control = $MainMenuUI
@onready var login_ui: Control = $LoginUI
@onready var create_account_ui: Control = $CreateAccountUI
@onready var lobby_ui: Control = $LobbyUI

enum CurrentUIScene {
	MainMenu,
	LoginUI,
	LobbyUI,
	CreateAccountUI
}

var current_ui_scene = CurrentUIScene.MainMenu

func _ready() -> void:
	main_menu_ui.connect("create_account_pressed", main_menu_create_account_pressed)
	main_menu_ui.connect("login_pressed", main_menu_login_pressed)
	create_account_ui.connect("back_pressed", create_account_back_pressed)
	login_ui.connect("back_pressed", login_menu_back_pressed)
	login_ui.connect("success_login", login_success)
	render_ui_scene()
	
func render_ui_scene():
	main_menu_ui.hide()
	login_ui.hide()
	lobby_ui.hide()
	create_account_ui.hide()
	
	match current_ui_scene:
		CurrentUIScene.MainMenu:
			main_menu_ui.show()
		CurrentUIScene.LoginUI:
			login_ui.show()
		CurrentUIScene.LobbyUI:
			lobby_ui.show()
		CurrentUIScene.CreateAccountUI:
			create_account_ui.show()
	
func main_menu_create_account_pressed() -> void:
	current_ui_scene = CurrentUIScene.CreateAccountUI
	render_ui_scene()
	
func main_menu_login_pressed() -> void:
	current_ui_scene = CurrentUIScene.LoginUI
	render_ui_scene()

func create_account_back_pressed() -> void:
	current_ui_scene = CurrentUIScene.MainMenu
	render_ui_scene()

func login_menu_back_pressed() -> void:
	current_ui_scene = CurrentUIScene.MainMenu
	render_ui_scene()

func login_success() -> void:
	current_ui_scene = CurrentUIScene.LobbyUI
	render_ui_scene()
