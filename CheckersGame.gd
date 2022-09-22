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
	match(colour):
		"white":
			new_piece.set_texture( WHITE_PIECE )
			$Board/Pieces/WhitePieces.add_child(new_piece)
		"black":
			new_piece.set_texture( BLACK_PIECE )
			$Board/Pieces/BlackPieces.add_child(new_piece)
		_:
			print("spawn_piece failed!")


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
	if carried_piece.get("can_move").has("up"):
		var target_row = starting_spot.y-1
		while target_row >= 0:
			target_row -= 1
	if carried_piece.get("can_move").has("down"):
		pass


func spawn_highlight(pos: Vector2, type="move"):
	var new_highlight = MOVE_HIGHLIGHT.instantiate()
	new_highlight.move_here.connect(_on_move_highlight_move_here)
	if type == "return":
		new_highlight.set_texture( HIGHLIGHT_RETURN )
		new_highlight.set("is_action", false)
	new_highlight.set_position(pos)
	$Board/Pieces/Highlights.add_child(new_highlight)


func _on_move_highlight_move_here(highlight):
	if highlight.get("is_action"):
		pass #not putting the piece back where it was
	
	carried_piece.set_position( highlight.get_position() )
	carried_piece.set_z_index(0)
	carried_piece = null
	
	set_all_pieces_pickable(true)
	
	for each_child in $Board/Pieces/Highlights.get_children():
		each_child.queue_free()


func set_all_pieces_pickable(boolean):
	for each_piece in $Board/Pieces/BlackPieces.get_children():
		each_piece.set_pickable(boolean)
	for each_piece in $Board/Pieces/WhitePieces.get_children():
		each_piece.set_pickable(boolean)
