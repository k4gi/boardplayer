extends HBoxContainer


@rpc(any_peer)
func add_message(message: String):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "remote_pickup_piece", message)


@rpc(any_peer)
func _on_ready_button_toggled(button_pressed):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "remote_pickup_piece", button_pressed)
