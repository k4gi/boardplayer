extends Node


signal start_button_for_players(client_peer_ids, is_disabled)
signal hide_online_ready_for_players(client_peer_ids)


const GAME_INSTANCE = preload("res://GameInstance.tscn")


var game_instance_index = {}


@rpc("any_peer", "reliable")
func pickup_piece(piece_pos: Vector2i):
	var remote_sender = multiplayer.get_remote_sender_id()
	var server_piece = game_instance_index[remote_sender].piece_array[piece_pos.x][piece_pos.y]
	
	if server_piece == null:
		print("pickup_piece discrepancy - $d no piece at %d,%d" % [remote_sender, piece_pos.x, piece_pos.y])
		return
	
	if game_instance_index[remote_sender].client_peer_ids[server_piece.get("allegiance")] != remote_sender:
		print("pickup_piece discrepancy - $d does not control piece at %d,%d" % [remote_sender, piece_pos.x, piece_pos.y])
		return
	
	#alright the piece exists and we're allowed to move it. now we need to send highlight positions
	var highlights = game_instance_index[remote_sender].get_highlights(piece_pos)
	rpc_id(remote_sender, "spawn_highlights", piece_pos, highlights)


@rpc("reliable")
func sync_board(server_piece_array, turn, score):
	pass #dummy


@rpc("reliable")
func spawn_highlights(piece_pos, highlights):
	pass #dummy


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
