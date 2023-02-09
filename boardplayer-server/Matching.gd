extends Node


signal create_game(challenger_id, challengee_id)


@rpc
func refresh_player_list():
	rpc("refresh_player_list", Global.player_names)


@rpc(any_peer)
func send_challenge(id_number):
	var remote_sender = multiplayer.get_remote_sender_id()
	rpc_id(id_number, "receive_challenge", remote_sender)


@rpc(any_peer)
func accept_challenge(id_number):
	var remote_sender = multiplayer.get_remote_sender_id()
	Global.opponents[remote_sender] = id_number
	Global.opponents[id_number] = remote_sender
	emit_signal("create_game", id_number, remote_sender)
