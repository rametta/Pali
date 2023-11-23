extends Node

@onready var main_menu_ui = $MainMenuUI

var is_server = false

func _ready() -> void:
	is_server = OS.has_feature("dedicated_server")
	
	if is_server:
		print("This is a server")
		on_create_server_pressed()
	else:
		print("This is a client")
		main_menu_ui.connect("join_server_pressed", on_join_server_pressed)
		main_menu_ui.connect("create_server_pressed", on_create_server_pressed)
		
func on_join_server_pressed(display_name: String):
	print("Join server btn pressed with name %s" % display_name)
	var client_scene = load("res://Scenes/Client/Client.tscn")
	var client = client_scene.instantiate()
	add_child(client)

func on_create_server_pressed():
	is_server = true
	print("Create server btn pressed")
	var server_scene = load("res://Scenes/Server/Server.tscn")
	var server = server_scene.instantiate()
	server.connect("start_game", on_start_game)
	add_child(server)
	main_menu_ui.hide()

func on_start_game():
	create_world.rpc()

@rpc
func create_world() -> void:
	print("[%s] Create world called" % multiplayer.get_unique_id())
	main_menu_ui.hide()
	var world_scene = load("res://Scenes/Main/Main.tscn")
	var world = world_scene.instantiate()
	add_child(world)
