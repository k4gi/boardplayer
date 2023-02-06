extends Node2D


@rpc(any_peer)
func remote_control_piece(pos):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "remote_control_piece", pos)


@rpc(any_peer)
func remote_pickup_piece(coords: Vector2i, grab_position: Vector2):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "remote_pickup_piece", coords, grab_position)


@rpc(any_peer)
func move_without_taking_piece(piece_in_array: Vector2i, highlight_pos):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "move_without_taking_piece", piece_in_array, highlight_pos)


@rpc(any_peer)
func move_with_taking_piece(piece_in_array: Vector2i, highlight_pos, taking_piece_position, taking_piece_allegiance):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "move_with_taking_piece", piece_in_array, highlight_pos, taking_piece_position, taking_piece_allegiance)


@rpc(any_peer)
func finish_taking_pieces(highlight_pos):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "finish_taking_pieces", highlight_pos)

