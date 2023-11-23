extends Node

signal card_selected(id: int)

const PORT: int = 50001
const SERVER_ADDRESS: String = "localhost" # "157.245.129.204"

enum CARD_ZONE {
	DECK,
	TABLE,
	PLAYER_1_HAND,
	PLAYER_2_HAND
}

var selected_card_id = null :
	set(new_value):
		selected_card_id = new_value
		card_selected.emit(new_value)
	get:
		return selected_card_id
