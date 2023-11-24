extends Control

@export var title_label: Label

func update_title(is_my_turn: bool) -> void:
	if is_my_turn:
		title_label.text = "It is your turn!"
	else:
		title_label.text = "It is your opponents turn"
