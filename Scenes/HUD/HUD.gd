extends Control

@export var title_label: Label
@export var player_1_label: Label
@export var player_2_label: Label

func update_title(is_my_turn: bool) -> void:
	if is_my_turn:
		title_label.text = "It is your turn!"
	else:
		title_label.text = "It is your opponents turn"


func update_player_1_label(title: String, score: int) -> void:
	player_1_label.text = "%s\n%d" % [title, score]
	
func update_player_2_label(title: String, score: int) -> void:
	player_2_label.text = "%s\n%d" % [title, score]
