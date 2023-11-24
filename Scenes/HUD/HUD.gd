extends Control

@export var game_time_label: Label
@export var texture_rect: TextureRect

func _ready() -> void:
	Global.card_selected.connect(on_card_selected)

func update_game_time(time_sec: int) -> void:
	var time = Time.get_time_dict_from_unix_time(time_sec)
	game_time_label.text = "%d:%02d" % [time.minute, time.second]

func reset_texture() -> void:
	texture_rect.texture = null

func on_card_selected(card_name) -> void:
	if not card_name:
		return reset_texture()
		
	var card: Node3D = get_node("/root/").find_child(card_name)
	if not card:
		return reset_texture()
		
	texture_rect.texture = card.card_resource.texture
