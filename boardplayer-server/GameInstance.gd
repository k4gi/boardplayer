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
	
	get_parent().sync_board_with(client_peer_ids, piece_array, turn, score)


func spawn_piece(x, y, facing, colour):
	var new_piece = {}
	new_piece["can_move"] = []
	new_piece["can_move"].append(facing)
	new_piece["allegiance"] = colour
	piece_array[x][y] = new_piece


func get_highlights(piece_pos, jumps_only = false):# -> Array:
	var output_highlights = []
	# a "highlight" is a dictionary, let's say
	#with a position x y in the grid
	#and a taking_piece position x y in the grid. for when you're jumping. so we can keep track of who to delete.
	
	var target_rows = []
	if piece_array[piece_pos.x][piece_pos.y]["can_move"].has("up") and piece_pos.y-1 >= 0:
		target_rows.append( -1 )
	if piece_array[piece_pos.x][piece_pos.y]["can_move"].has("down") and piece_pos.y+1 < 8:
		target_rows.append( 1 )
	
	for y_diff in target_rows:
		for x_diff in [-1, 1]:
			var target_spot = Vector2i(piece_pos.x+x_diff, piece_pos.y+y_diff)
			
			if target_spot.x >= 0 and target_spot.x < 8:
				var occupying_piece = piece_array[target_spot.x][target_spot.y]
				
				if occupying_piece == null and not jumps_only:
					var new_highlight = {}
					new_highlight["pos"] = target_spot
					new_highlight["taking_piece_pos"] = null
					output_highlights.append( new_highlight )
				
				elif occupying_piece != null and occupying_piece["allegiance"] != piece_array[piece_pos.x][piece_pos.y]["allegiance"]:
					var second_target_spot = Vector2i(piece_pos.x+(x_diff*2), piece_pos.y+(y_diff*2))
					if second_target_spot.x >= 0 and second_target_spot.x < 8 and second_target_spot.y >= 0 and second_target_spot.y < 8:
						var second_occupying_piece = piece_array[second_target_spot.x][second_target_spot.y]
						if second_occupying_piece == null:
							var new_highlight = {}
							new_highlight["pos"] = second_target_spot
							new_highlight["taking_piece_pos"] = target_spot
							output_highlights.append( new_highlight )
	
	return output_highlights
