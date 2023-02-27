extends Node2D


signal turn_toggled( turn )
signal game_won( score )


const WHITE_PIECE = preload("res://WhitePiece.tres")
const BLACK_PIECE = preload("res://BlackPiece.tres")
const WHITE_KING = preload("res://WhiteKing.tres")
const BLACK_KING = preload("res://BlackKing.tres")
const HIGHLIGHT_SQUARE = preload("res://MoveHighlight.tres")
const HIGHLIGHT_RETURN = preload("res://ReturnHighlight.tres")

const CHECKERS_PIECE = preload("res://CheckersPiece.tscn")
const MOVE_HIGHLIGHT = preload("res://MoveHighlight.tscn")


var i_can_move = ["white", "black"]

var carrying_piece


@rpc("any_peer", "reliable")
func pickup_piece(piece_pos: Vector2i):
	pass


@rpc("reliable")
func sync_board(server_piece_array, turn, score):
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
				new_piece.set("grid_position", Vector2i(x,y))
				for each_direction in server_piece_array[x][y]["can_move"]:
					new_piece.get("can_move").append(each_direction)
				new_piece.set("allegiance", server_piece_array[x][y]["allegiance"] )
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
						new_piece.queue_free()
			y += 1
		x += 1
	
	if score["white"] == 0 or score["black"] == 0:
		emit_signal("game_won", score)
	else:
		emit_signal("turn_toggled", turn)
		set_all_pieces_pickable(false)
		set_all_pieces_pickable(true, turn)


@rpc("reliable")
func spawn_highlights(piece_pos, highlights, spawn_return=true):
	if spawn_return:
		spawn_highlight(piece_pos, null, "return")
	for each_highlight in highlights:
		spawn_highlight(each_highlight["pos"], each_highlight["taking_piece_pos"])


@rpc("any_peer", "reliable")
func move_piece(piece_pos: Vector2i, highlight_pos: Vector2i, taking_piece_pos):
	pass #dummy


func spawn_highlight(pos: Vector2i, taking_piece_pos, type="move"):
	var new_highlight = MOVE_HIGHLIGHT.instantiate()
	new_highlight.move_here.connect(_on_move_highlight_move_here)
	if type == "return":
		new_highlight.set_texture( HIGHLIGHT_RETURN )
		new_highlight.set("is_action", false)
	new_highlight.set_position($Board.map_to_local(pos))
	new_highlight.set("is_taking_piece", taking_piece_pos)
	$Board/Highlights.add_child(new_highlight)


func set_all_pieces_pickable(boolean, target_colour="both"):
	if target_colour != "black" and i_can_move.has("white"):
		for each_piece in $Board/WhitePieces.get_children():
			each_piece.set_pickable(boolean)
	if target_colour != "white" and i_can_move.has("black"):
		for each_piece in $Board/BlackPieces.get_children():
			each_piece.set_pickable(boolean)


func _process(_delta):
	if carrying_piece != null:
		carrying_piece.set_global_position( get_global_mouse_position() + carrying_piece.get("grab_position") )


func _on_checkers_piece_pickup_piece(piece):
	if i_can_move.has( piece.get("allegiance") ):
		rpc_id(1, "pickup_piece", piece.get("grid_position"))
		#maybe it's fine to pickup the piece here
		#since the client thinks it's ok
		piece.set( "grab_position", piece.get_global_position() - get_global_mouse_position() )
		piece.set_z_index(1)
		set_all_pieces_pickable(false)
		carrying_piece = piece


func _on_move_highlight_move_here(highlight):
	var is_action = highlight.get("is_action")
	var taking_piece = highlight.get("is_taking_piece")
	var highlight_pos = highlight.get_position()
	
	if not is_action: #not making a move
		put_piece_back_down(highlight_pos)
	#maybe it doesn't matter clientside whether i'm taking a piece.
	#the server needs to verify anyway
	else:
		rpc_id(1, "move_piece", carrying_piece.get("grid_position"), $Board.local_to_map(highlight_pos), highlight.get("is_taking_piece"))

	for each_child in $Board/Highlights.get_children():
		$Board/Highlights.remove_child( each_child )
		each_child.queue_free()
#	elif taking_piece == null: #making a move but not taking a piecee
#		pass
#	else: #taking a piece!!!
#		pass
#		#test whether we can take more pieces
#		for each_child in $Board/Highlights.get_children():
#			$Board/Highlights.remove_child( each_child )
#			each_child.queue_free()
#
#		#more highlights here
#
#		if $Board/Highlights.get_child_count() == 0:
#			pass #finished
#		else:
#			#if jumping is not mandatory
#			pass


func put_piece_back_down( highlight_pos ):
	carrying_piece.set_position( highlight_pos )
	carrying_piece.set_z_index(0)
	carrying_piece = null
	for each_highlight in $Board/Highlights.get_children():
		each_highlight.queue_free()
	set_all_pieces_pickable(true)#, turn)
	#whose turn is it?
