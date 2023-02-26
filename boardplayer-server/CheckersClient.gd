extends Node


signal start_button_for_players(client_peer_ids, is_disabled)
signal hide_online_ready_for_players(client_peer_ids)


const GAME_INSTANCE = preload("res://GameInstance.tscn")


var game_instance_index = {}


@rpc("any_peer", "reliable")
func pickup_piece(piece_pos: Vector2i):
	var remote_sender = multiplayer.get_remote_sender_id()
	var piece_array = game_instance_index[remote_sender].get("piece_array")
	
	if not detect_piece_pos_discrepancies(remote_sender, piece_array, piece_pos):
		#alright the piece exists and we're allowed to move it. now we need to send highlight positions
		var highlights = game_instance_index[remote_sender].get_highlights(piece_pos)
		rpc_id(remote_sender, "spawn_highlights", piece_pos, highlights)


@rpc("reliable")
func sync_board(server_piece_array, turn, score):
	pass #dummy


@rpc("reliable")
func spawn_highlights(piece_pos, highlights, spawn_return=true):
	pass #dummy


@rpc("any_peer", "reliable")
func move_piece(piece_pos: Vector2i, highlight_pos: Vector2i, taking_piece_pos):
	var remote_sender = multiplayer.get_remote_sender_id()
	var piece_array = game_instance_index[remote_sender].get("piece_array")
	
	if not detect_piece_pos_discrepancies(remote_sender, piece_array, piece_pos) or \
		detect_highlight_pos_discrepancies(remote_sender, piece_array, piece_pos, highlight_pos, taking_piece_pos):
			#we can move the piece now
			var move_result = game_instance_index[remote_sender].move_piece(piece_pos, highlight_pos, taking_piece_pos)
			if move_result == "game_won":
				return
			if move_result != null:
				rpc_id(remote_sender, "spawn_highlights", highlight_pos, move_result, false)


func detect_piece_pos_discrepancies(remote_sender: int, piece_array: Array, piece_pos: Vector2i) -> bool:
	if piece_pos.x < 0 or piece_pos.x >= 8 or piece_pos.y < 0 or piece_pos.y >= 8:
		print("piece_pos discrepancy - %d piece is off the board %d,%d" % [remote_sender, piece_pos.x, piece_pos.y])
		return true
	
	if piece_array[piece_pos.x][piece_pos.y] == null:
		print("piece_pos discrepancy - %d no piece at %d,%d" % [remote_sender, piece_pos.x, piece_pos.y])
		return true
	
	if game_instance_index[remote_sender].client_peer_ids[piece_array[piece_pos.x][piece_pos.y].get("allegiance")] != remote_sender:
		print("piece_pos discrepancy - %d does not control piece at %d,%d" % [remote_sender, piece_pos.x, piece_pos.y])
		return true
		
	if game_instance_index[remote_sender].get("turn") != piece_array[piece_pos.x][piece_pos.y].get("allegiance"):
		print("piece_pos discrepancy - %d not your turn" % remote_sender)
		return true
	
	return false


func detect_highlight_pos_discrepancies(remote_sender: int, piece_array: Array, piece_pos: Vector2i, highlight_pos: Vector2i, taking_piece_pos) -> bool:
	if highlight_pos.x < 0 or highlight_pos.x >= 8 or highlight_pos.y < 0 or highlight_pos.y >= 8:
		print("highlight_pos discrepancy - %d highlight is off the board %d,%d" % [remote_sender, highlight_pos.x, highlight_pos.y])
		return true
	
	if piece_array[highlight_pos.x][highlight_pos.y] != null:
		print("highlight_pos discrepancy - %d piece at %d,%d" % [remote_sender, highlight_pos.x, highlight_pos.y])
		return true

	if ( highlight_pos.y < piece_pos.y and not piece_array[piece_pos.x][piece_pos.y]["can_move"].has("up") ) or \
		( highlight_pos.y > piece_pos.y and not piece_array[piece_pos.x][piece_pos.y]["can_move"].has("down") ):
			print("highlight_pos discrepancy - %d highlight is in the wrong direction %d,%d from piece %d,%d" % \
				[remote_sender, highlight_pos.x, highlight_pos.y, piece_pos.x, piece_pos.y])
			return true
	
	if taking_piece_pos == null:
		#and whether it's only moving one step
		if absi( highlight_pos.x - piece_pos.x ) != 1 or absi( highlight_pos.y - piece_pos.y ) != 1:
			print("highlight_pos discrepancy - %d not taking piece, moving to invalid square %d,%d from piece %d,%d" % \
				[remote_sender, highlight_pos.x, highlight_pos.y, piece_pos.x, piece_pos.y])
			return true
	else:
		#or whether it's moving two steps
		if absi( highlight_pos.x - piece_pos.x ) != 2 or absi( highlight_pos.y - piece_pos.y ) != 2:
			print("highlight_pos discrepancy - %d taking piece, moving to invalid square %d,%d from piece %d,%d" % \
				[remote_sender, highlight_pos.x, highlight_pos.y, piece_pos.x, piece_pos.y])
			return true
		#and the taking piece is on the first step
		if highlight_pos.x - piece_pos.x > 0 and taking_piece_pos.x - piece_pos.x != 1 or \
			highlight_pos.x - piece_pos.x < 0 and taking_piece_pos.x - piece_pos.x != -1 or \
			highlight_pos.y - piece_pos.y > 0 and taking_piece_pos.y - piece_pos.y != 1 or \
			highlight_pos.y - piece_pos.y < 0 and taking_piece_pos.y - piece_pos.y != -1:
				print("highlight_pos discrepancy - %d taking piece %d,%d is not between highlight %d,%d and piece %d,%d" % \
				[remote_sender, taking_piece_pos.x, taking_piece_pos.y, highlight_pos.x, highlight_pos.y, piece_pos.x, piece_pos.y])
				return true
		#finally is there a piece at taking_piece_pos and is it your enemy
		if piece_array[taking_piece_pos.x][taking_piece_pos.y] == null:
			print("highlight_pos discrepancy - %d no piece to take at %d,%d" % [remote_sender, taking_piece_pos.x, taking_piece_pos.y])
			return true
		
		if piece_array[taking_piece_pos.x][taking_piece_pos.y]["allegiance"] == piece_array[piece_pos.x][piece_pos.y]["allegiance"]:
			print("highlight_pos discrepancy - %d trying to take own piece" % remote_sender)
			return true
	
	return false

func create_new_game(white_peer_id, black_peer_id):
	var new_instance = GAME_INSTANCE.instantiate()
	
	new_instance.client_peer_ids["white"] = white_peer_id
	new_instance.client_peer_ids["black"] = black_peer_id
	
	game_instance_index[white_peer_id] = new_instance
	game_instance_index[black_peer_id] = new_instance
	
	new_instance.start_button_for_players.connect(_on_game_instance_start_button_for_players)
	new_instance.hide_online_ready_for_players.connect(_on_game_instance_hide_online_ready_for_players)
	
	add_child(new_instance)


func sync_board_with(client_peer_ids, server_piece_array, turn, score):
	rpc_id(client_peer_ids["white"], "sync_board", server_piece_array, turn, score)
	rpc_id(client_peer_ids["black"], "sync_board", server_piece_array, turn, score)


#crossways signal connection! object orientation be damned!

func _on_online_ready_ready_pressed(button_pressed, remote_sender):
	game_instance_index[remote_sender].set_ready(button_pressed, remote_sender)


func _on_online_ready_start_pressed(remote_sender):
	game_instance_index[remote_sender].start_game()


func _on_game_instance_start_button_for_players(client_peer_ids, is_disabled):
	emit_signal("start_button_for_players", client_peer_ids, is_disabled)


func _on_game_instance_hide_online_ready_for_players(client_peer_ids):
	emit_signal("hide_online_ready_for_players", client_peer_ids)
