extends Node


@rpc(any_peer)
func remote_control_piece(pos):
	pass


@rpc(any_peer)
func remote_pickup_piece(coords: Vector2i, grab_position: Vector2):
	pass


@rpc(any_peer, call_local)
func move_without_taking_piece(piece_in_array: Vector2i, highlight_pos):
	pass


@rpc(any_peer, call_local)
func move_with_taking_piece(piece_in_array: Vector2i, highlight_pos, taking_piece_position, taking_piece_allegiance):
	pass


@rpc(any_peer, call_local)
func finish_taking_pieces(highlight_pos):
	pass

