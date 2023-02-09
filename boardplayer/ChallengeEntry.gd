extends PanelContainer


signal accept_challenge(id_number)
signal decline_challenge(id_number)


var challenger_id


func set_challenger_id(id_number):
	challenger_id = id_number


func set_challenger_name(player_name):
	$VBox/HBox/ChallengerName.set_text( player_name )


func _on_accept_challenge_pressed():
	emit_signal("accept_challenge", challenger_id)


func _on_decline_challenge_pressed():
	emit_signal("decline_challenge", challenger_id)
