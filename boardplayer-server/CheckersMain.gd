extends Node


@rpc(any_peer)
func create_game():
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "create_game")


@rpc(any_peer)
func set_opponent_peer_id(id):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "set_opponent_peer_id", id)
