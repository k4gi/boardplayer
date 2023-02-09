extends VBoxContainer


signal send_challenge(id_number)


func set_player_id(id_number):
	$HBox/PlayerID.set_text( str(id_number) )


func set_player_name(player_name):
	$HBox/PlayerName.set_text( player_name )


func _on_send_challenge_pressed():
	emit_signal("send_challenge", int($HBox/PlayerID.get_text()) )


func disable_challenge_button():
	$HBox/SendChallenge.set_disabled(true)
