extends Node


const CHECKERS_PIECE = preload("res://CheckersPiece.tscn")

const TILE_BEIGE = Vector2i(0,0)
const TILE_RED = Vector2i(1,0)

var board_array = []

var piece_array = []

var score = {
	"white": 12,
	"black": 12,
}

var turn = "white"

var client_peer_ids = {}

var clients_ready = [false, false]


func start_game():
	#build piece_array and board_array
	var tile_toggle_red = false
	
	for x in range(8):
		piece_array.append( [] )
		board_array.append( [] )
		for y in range(8):
			piece_array[x].append( null )
			if tile_toggle_red:
				board_array[x].append( TILE_RED )
			else:
				board_array[x].append( TILE_BEIGE )
			tile_toggle_red = !tile_toggle_red
	
	for first_three in range(0,3):
		for x in range(8):
			if board_array[x][first_three] == TILE_RED:
				spawn_piece(x, first_three, "down", "white")
	for last_three in range(5,8):
		for x in range(8):
			if board_array[x][last_three] == TILE_RED:
				spawn_piece(x, last_three, "up", "black")
	
	get_parent().sync_board_with(client_peer_ids, piece_array)


func spawn_piece(x, y, facing, colour):
	var new_piece = CHECKERS_PIECE.instantiate()
	new_piece.get("can_move").append(facing)
	new_piece.set("allegience", colour)
	piece_array[x][y] = new_piece

