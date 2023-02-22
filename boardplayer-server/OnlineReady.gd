extends Node


signal ready_pressed(button_pressed, remote_sender)
signal start_pressed(remote_sender)


@rpc("any_peer", "reliable")
func ready_button_pressed(button_pressed):
	print("ready button pressed")
	var remote_sender = multiplayer.get_remote_sender_id()
	emit_signal("ready_pressed", button_pressed, remote_sender)
	rpc_id(remote_sender, "ready_button_received")


@rpc("any_peer", "reliable")
func start_game_pressed():
	var remote_sender = multiplayer.get_remote_sender_id()
	emit_signal("start_pressed", remote_sender)


@rpc("reliable")
func ready_button_received():
	pass #dummy


@rpc("reliable")
func start_button_disable(boolean: bool):
	pass #dummy


@rpc("reliable")
func hide_online_ready():
	pass #dummy


func start_button_for_players(client_peer_ids, boolean: bool):
	rpc_id(client_peer_ids["white"], "start_button_disable", boolean)


func hide_for_players(client_peer_ids):
	rpc_id(client_peer_ids["white"], "hide_online_ready")
	rpc_id(client_peer_ids["black"], "hide_online_ready")
