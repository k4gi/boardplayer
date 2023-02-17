extends Node


const GAME_INSTANCE = preload("res://GameInstance.tscn")


var game_instance_index = {}


func create_new_game(white_peer_id, black_peer_id):
	var new_instance = GAME_INSTANCE.instantiate()
	
	new_instance.client_peer_ids["white"] = white_peer_id
	new_instance.client_peer_ids["black"] = black_peer_id
	
	new_instance.start_game()
	
	game_instance_index[white_peer_id] = new_instance
	game_instance_index[black_peer_id] = new_instance
	
	add_child(new_instance)


@rpc("any_peer", "reliable")
func pickup_piece(piece_pos: Vector2i):
	pass #idk lol


func sync_board_with(client_peer_ids, server_piece_array):
	rpc_id(client_peer_ids["white"], "sync_board", server_piece_array)
	rpc_id(client_peer_ids["black"], "sync_board", server_piece_array)


@rpc("reliable")
func sync_board(server_piece_array):
	pass #dummy
