extends Node

signal on_game_status_change(gs: GAME_STATUS)
signal on_player_turn_change(pl: PLAYER)

enum GAME_STATUS {
	PRE_GAME,
	IN_PROGRESS,
	POST_GAME
}

enum PLAYER {
	ONE,
	TWO,
	SERVER
}

var game_status: GAME_STATUS = GAME_STATUS.PRE_GAME
var player_turn: PLAYER = PLAYER.ONE

@rpc("call_local")
func update_game_status(gs: GAME_STATUS) -> void:
	game_status = gs
	on_game_status_change.emit(gs)
	
@rpc("call_local")
func update_player_turn(p: PLAYER) -> void:
	player_turn = p
	on_player_turn_change.emit(p)
