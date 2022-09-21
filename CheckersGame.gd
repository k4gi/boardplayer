extends Node2D


const WHITE_PIECE = preload("res://WhitePiece.tres")
const BLACK_PIECE = preload("res://BlackPiece.tres")
const HIGHLIGHT_SQUARE = preload("res://MoveHighlight.tres")
const HIGHLIGHT_RETURN = preload("res://ReturnHighlight.tres")


var carried_piece = null


func _process(_delta):
	if carried_piece != null:
		carried_piece.set_global_position( get_global_mouse_position() + carried_piece.get("grab_position") )


func _on_checkers_piece_pickup_piece(piece):
	piece.grab_position = piece.get_global_position() - get_global_mouse_position()
	piece.set_pickable(false)
	piece.set_z_index(1) #want held piece to be above all others
	
	carried_piece = piece


func _on_move_highlight_move_here(highlight):
	carried_piece.set_position( highlight.get_position() )
	carried_piece.set_pickable(true)
	carried_piece.set_z_index(0)
	carried_piece = null
	
	if highlight.get("is_action"):
		pass #not putting the piece back where it was
	
	
	for each_child in $Board/Pieces/Highlights.get_children():
		each_child.queue_free()
	
