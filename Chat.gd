extends ScrollContainer


@rpc(any_peer)
func add_message(message: String):
	var new_label = Label.new()
	new_label.set_text( "%s: %s" % [multiplayer.get_remote_sender_id(), message] )
	$HBox/VBoxChat.add_child(new_label)


func _on_ready_button_pressed():
	rpc("client_says_ready")


@rpc(any_peer)
func client_says_ready():
	print("aaaaaa")


func _on_chat_entry_text_submitted(new_text):
	send_chat_message(new_text)


func _on_chat_send_pressed():
	send_chat_message( $HBox/VBoxControls/HBoxChatEntry/ChatEntry.get_text() )


func send_chat_message(message: String):
	add_message(message)
	rpc("add_message", message)
	$HBox/VBoxControls/HBoxChatEntry/ChatEntry.clear()
