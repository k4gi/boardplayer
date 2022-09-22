extends Node2D


const WHITE_PIECE = preload("res://WhitePiece.tres")
const BLACK_PIECE = preload("res://BlackPiece.tres")
const HIGHLIGHT_SQUARE = preload("res://MoveHighlight.tres")
const HIGHLIGHT_RETURN = preload("res://ReturnHighlight.tres")

const CHECKERS_PIECE = preload("res://CheckersPiece.tscn")
const MOVE_HIGHLIGHT = preload("res://MoveHighlight.tscn")


const TILE_BEIGE = Vector2i(0,0)
const TILE_RED = Vector2i(1,0)


var carried_piece = null


func _ready():
	#spawn in pieces
	var board_coords = $Board.get_used_cells(0)
	for first_three in range(0,3):
		for x in range(8):
			if $Board.get_cell_atlas_coords(0, Vector2i(x,first_three)) == TILE_RED:
				spawn_piece(x, first_three, "down", "white")
	for last_three in range(5,8):
		for x in range(8):
			if $Board.get_cell_atlas_coords(0, Vector2i(x,last_three)) == TILE_RED:
				spawn_piece(x, last_three, "up", "black")


func spawn_piece(x,y,facing,colour):
	var new_piece = CHECKERS_PIECE.instantiate()
	
	new_piece.pickup_piece.connect(_on_checkers_piece_pickup_piece)
	
	new_piece.set_position( $Board.map_to_local( Vector2i(x, y) ) )
	new_piece.get("can_move").append( facing )
	new_piece.set("allegiance", colour)
	match(colour):
		"white":
			new_piece.set_texture( WHITE_PIECE )
			$Board/Pieces.add_child(new_piece)
		"black":
			new_piece.set_texture( BLACK_PIECE )
			$Board/Pieces.add_child(new_piece)
		_:
			print("spawn_piece failed!")
			new_piece.queue_free()


func _process(_delta):
	if carried_piece != null:
		carried_piece.set_global_position( get_global_mouse_position() + carried_piece.get("grab_position") )


func _on_checkers_piece_pickup_piece(piece):
	piece.grab_position = piece.get_global_position() - get_global_mouse_position()
	piece.set_z_index(1) #want held piece to be above all others
	
	carried_piece = piece
	
	set_all_pieces_pickable(false)
	
	spawn_highlight(piece.get_position(), "return")
	
	place_highlights()


func place_highlights():
	var starting_spot = $Board.local_to_map(carried_piece.get_position())
	
	var target_rows = []
	if carried_piece.get("can_move").has("up") and starting_spot.y-1 >= 0:
		target_rows.append( starting_spot.y-1 )
	if carried_piece.get("can_move").has("down") and starting_spot.y+1 < 8:
		target_rows.append( starting_spot.y+1 )
	
	for each_row in target_rows:
		if starting_spot.x-1 >= 0: #left
			var occupying_piece = null
			for each_child in $Board/Pieces.get_children():
				if each_child.get_position() == $Board.map_to_local( Vector2i(starting_spot.x-1, each_row) ):
					occupying_piece = each_child
					break
			if occupying_piece != null and occupying_piece.get("allegiance") != carried_piece.get("allegiance"):
				var second_occupying_piece = null
				for each_child in $Board/Pieces.get_children():
					# ahhh this is so convoluted
					# just give me recursion
					pass
		
		if starting_spot.x+1 < 8: #right
			pass


func spawn_highlight(pos: Vector2i, type="move"):
	var new_highlight = MOVE_HIGHLIGHT.instantiate()
	new_highlight.move_here.connect(_on_move_highlight_move_here)
	if type == "return":
		new_highlight.set_texture( HIGHLIGHT_RETURN )
		new_highlight.set("is_action", false)
	new_highlight.set_position(pos)
	$Board/Highlights.add_child(new_highlight)


func _on_move_highlight_move_here(highlight):
	if highlight.get("is_action"):
		pass #not putting the piece back where it was
	
	carried_piece.set_position( highlight.get_position() )
	carried_piece.set_z_index(0)
	carried_piece = null
	
	set_all_pieces_pickable(true)
	
	for each_child in $Board/Highlights.get_children():
		each_child.queue_free()


func set_all_pieces_pickable(boolean):
	for each_piece in $Board/Pieces.get_children():
		each_piece.set_pickable(boolean)
	for each_piece in $Board/Pieces.get_children():
		each_piece.set_pickable(boolean)
