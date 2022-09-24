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


#what if the checkers pieces were stored in a 2d array. wouldn't that be better
var piece_array = []

#how to win!
var score = {
	"white": 12,
	"black": 12,
}


func _ready():
	#build piece_array
	for x in range(8):
		piece_array.append( [] )
		for y in range(8):
			piece_array[x].append( null )
	
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
			piece_array[x][y] = new_piece
			$Board/Pieces.add_child(new_piece)
		"black":
			new_piece.set_texture( BLACK_PIECE )
			piece_array[x][y] = new_piece
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
	
	spawn_highlight(piece.get_position(), null, "return")
	
	place_highlights()


func place_highlights():
	var starting_spot = $Board.local_to_map(carried_piece.get_position())
	
	var target_rows = []
	if carried_piece.get("can_move").has("up") and starting_spot.y-1 >= 0:
		target_rows.append( -1 )
	if carried_piece.get("can_move").has("down") and starting_spot.y+1 < 8:
		target_rows.append( 1 )
	
	for y_diff in target_rows:
		for x_diff in [-1, 1]:
			var target_spot = Vector2i(starting_spot.x+x_diff, starting_spot.y+y_diff)
			
			if target_spot.x >= 0 and target_spot.x < 8:
				var occupying_piece = piece_array[target_spot.x][target_spot.y]
				
				if occupying_piece == null:
					spawn_highlight( $Board.map_to_local(target_spot), null )
				
				elif occupying_piece != null and occupying_piece.get("allegiance") != carried_piece.get("allegiance"):
					#space to jump?
					var second_target_spot = Vector2i(starting_spot.x+(x_diff*2), starting_spot.y+(y_diff*2))
					if second_target_spot.x >= 0 and second_target_spot.x < 8 and second_target_spot.y >= 0 and second_target_spot.y < 8:
						occupying_piece = piece_array[target_spot.x][target_spot.y]
						
						if occupying_piece == null:
							spawn_highlight( $Board.map_to_local(second_target_spot), target_spot )
		


func spawn_highlight(pos: Vector2i, taking_piece, type="move"):
	var new_highlight = MOVE_HIGHLIGHT.instantiate()
	new_highlight.move_here.connect(_on_move_highlight_move_here)
	if type == "return":
		new_highlight.set_texture( HIGHLIGHT_RETURN )
		new_highlight.set("is_action", false)
	new_highlight.set_position(pos)
	new_highlight.set("is_taking_piece", taking_piece)
	$Board/Highlights.add_child(new_highlight)


func _on_move_highlight_move_here(highlight):
	if highlight.get("is_action"):
		var tp = highlight.get("is_taking_piece")
		if tp != null:
			score[ piece_array[tp.x][tp.y].get("allegiance") ] -= 1
			piece_array[tp.x][tp.y].queue_free()
			piece_array[tp.x][tp.y] = null
		else:
			pass #end turn
		#something else needs to happen here
		#i forget. i'm sleepy
		#oh yeah. update the array locations
		var x = 0
		while x < 8:
			var y = 0
			while y < 8:
				if piece_array[x][y] == carried_piece:
					piece_array[x][y] = null
					x = 10
					y = 10
				y += 1
			x += 1
		var new_pos = $Board.local_to_map( highlight.get_position() )
		piece_array[new_pos.x][new_pos.y] = carried_piece
	
	carried_piece.set_position( highlight.get_position() )
	carried_piece.set_z_index(0)
	carried_piece = null
	
	set_all_pieces_pickable(true)
	
	for each_child in $Board/Highlights.get_children():
		each_child.queue_free()


func set_all_pieces_pickable(boolean):
	for each_piece in $Board/Pieces.get_children():
		each_piece.set_pickable(boolean)
