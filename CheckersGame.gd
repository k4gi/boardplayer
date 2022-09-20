extends Node2D


func _on_checkers_piece_pickup_piece(piece):
	print( $Board.local_to_map( piece.get_position() ) )


func _on_move_highlight_move_here(highlight):
	pass # Replace with function body.
