extends Node


signal ready_pressed(button_pressed, remote_sender)
signal start_pressed(remote_sender)


@rpc("any_peer", "reliable")
func ready_button_pressed(button_pressed):
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
