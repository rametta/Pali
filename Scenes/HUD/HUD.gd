extends Control

@export var game_time_label: Label

func update_game_time(time_sec: int) -> void:
	var time = Time.get_time_dict_from_unix_time(time_sec)
	game_time_label.text = "%d:%02d" % [time.minute, time.second]
