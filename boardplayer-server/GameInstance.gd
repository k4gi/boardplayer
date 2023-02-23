extends Node


signal start_button_for_players(client_peer_ids, is_disabled)
signal hide_online_ready_for_players(client_peer_ids)


const TILE_BEIGE = Vector2i(0,0)
const TILE_RED = Vector2i(1,0)


var piece_array = []

var score = {
	"white": 12,
	"black": 12,
}

var turn = "white"

var client_peer_ids = {}

var clients_ready = {"white": false, "black": false}


func set_ready(button_pressed, remote_sender):
	clients_ready[ client_peer_ids.find_key(remote_sender) ] = button_pressed
	if clients_ready["white"] and clients_ready["black"]:
		emit_signal("start_button_for_players", client_peer_ids, false) #enable button
	else:
		emit_signal("start_button_for_players", client_peer_ids, true) #disable button


func start_game():
	emit_signal("hide_online_ready_for_players", client_peer_ids)
	
	#build piece_array
	for x in range(8):
		piece_array.append( [] )
		for y in range(8):
			piece_array[x].append( null )
	
	for first_three in range(0,3):
		for x in range(8):
			if (x%2 == 0) != (first_three%2 == 0):
				spawn_piece(x, first_three, "down", "white")
	for last_three in range(5,8):
		for x in range(8):
			if (x%2 == 0) != (last_three%2 == 0):
				spawn_piece(x, last_three, "up", "black")
	
	get_parent().sync_board_with(client_peer_ids, piece_array)


func spawn_piece(x, y, facing, colour):
	var new_piece = {}
	new_piece["can_move"] = []
	new_piece["can_move"].append(facing)
	new_piece["allegiance"] = colour
	piece_array[x][y] = new_piece

