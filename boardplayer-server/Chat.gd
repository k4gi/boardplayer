extends Node


@rpc(any_peer)
func add_message(message: String):
	pass


@rpc(any_peer)
func _on_ready_button_toggled(button_pressed):
	pass
