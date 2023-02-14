extends Node2D


const WHITE_PIECE = preload("res://WhitePiece.tres")
const BLACK_PIECE = preload("res://BlackPiece.tres")
const WHITE_KING = preload("res://WhiteKing.tres")
const BLACK_KING = preload("res://BlackKing.tres")
const HIGHLIGHT_SQUARE = preload("res://MoveHighlight.tres")
const HIGHLIGHT_RETURN = preload("res://ReturnHighlight.tres")

const CHECKERS_PIECE = preload("res://CheckersPiece.tscn")
const MOVE_HIGHLIGHT = preload("res://MoveHighlight.tscn")


@rpc("reliable")
func sync_board(server_piece_array):
	#why not, just wipe the board every time
	for each_piece in $Board/BlackPieces.get_children():
		$Board/BlackPieces.remove_child(each_piece)
		each_piece.queue_free()
	for each_piece in $Board/WhitePieces.get_children():
		$Board/WhitePieces.remove_child(each_piece)
		each_piece.queue_free()
	
	var x = 0
	while x < 8:
		var y = 0
		while y < 8:
			if server_piece_array[x][y] != null:
				var new_piece = CHECKERS_PIECE.instantiate()
				new_piece.pickup_piece.connect(_on_checkers_piece_pickup_piece)
				new_piece.set_position($Board.map_to_local(Vector2i(x,y)))
				for each_direction in server_piece_array[x][y].get("can_move"):
					new_piece.get("can_move").append(each_direction)
				new_piece.set("allegiance", server_piece_array[x][y].get("allegiance") )
				match( new_piece.get("allegiance") ):
					"white":
						if new_piece.get("can_move").size() == 1:
							new_piece.set_texture( WHITE_PIECE )
						else:
							new_piece.set_texture( WHITE_KING )
						$Board/WhitePieces.add_child(new_piece)
					"black":
						if new_piece.get("can_move").size() == 1:
							new_piece.set_texture( BLACK_PIECE )
						else:
							new_piece.set_texture( BLACK_KING )
						$Board/BlackPieces.add_child(new_piece)
					_:
						print("board syncing has made a hecking mistake")
			y += 1
		x += 1


func _on_checkers_piece_pickup_piece(piece):
	rpc_id(1, "pickup_piece", $Board.local_to_map(piece.get_position()))


@rpc("any_peer", "reliable")
func pickup_piece(piece_pos: Vector2i):
	pass
