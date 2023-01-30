extends HBoxContainer


var ready_button_pressed = [false, false]


func _ready():
	$VBox/Scroll.get_v_scroll_bar().changed.connect(_on_scrollbar_changed)


@rpc(any_peer)
func add_message(message: String):
	var new_label = Label.new()
	var remote_sender = multiplayer.get_remote_sender_id()
	if remote_sender == 0:
		remote_sender = multiplayer.get_unique_id()
	new_label.set_text( "%s: %s" % [remote_sender, message] )
	$VBox/Scroll/VBoxChat.add_child(new_label)


func set_mp_status():
	var new_label = Label.new()
	new_label.set_text( "I am %s" % multiplayer.get_unique_id() )
	$VBox/VBoxMPStatus.add_child(new_label)


@rpc(any_peer)
func client_says_ready():
	print("aaaaaa")


func _on_chat_entry_text_submitted(new_text):
	send_chat_message(new_text)


func _on_chat_send_pressed():
	send_chat_message( $VBox/VBoxMPStatus/HBoxChatEntry/ChatEntry.get_text() )


func send_chat_message(message: String):
	add_message(message)
	rpc("add_message", message)
	$VBox/VBoxMPStatus/HBoxChatEntry/ChatEntry.clear()


@rpc(any_peer)
func _on_ready_button_toggled(button_pressed):
	var remote_sender = multiplayer.get_remote_sender_id()
	var unique_id = multiplayer.get_unique_id()
	
	if remote_sender == 0 and unique_id == 1:
		ready_button_pressed[0] = button_pressed
	elif remote_sender != 0 and unique_id == 1:
		ready_button_pressed[1] = button_pressed
	else:
		rpc("_on_ready_button_toggled", button_pressed)
		return
	
	add_message("%s pressed Ready (%s)" % [remote_sender, button_pressed])
	rpc("add_message", "%s pressed Ready (%s)" % [remote_sender, button_pressed])
	
	if unique_id == 1:
		if ready_button_pressed[0] and ready_button_pressed[1]:
			$VBox/VBoxControls/StartMultiGame.set_disabled(false)
		else:
			$VBox/VBoxControls/StartMultiGame.set_disabled(true)


func _on_scrollbar_changed(scrollbar):
	$VBox/Scroll.set_v_scroll($VBox/Scroll.get_v_scroll_bar().get_max())

