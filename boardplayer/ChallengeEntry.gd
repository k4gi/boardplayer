extends PanelContainer


signal accept_challange(id_number)
signal decline_challenge(id_number)


var challenger_id


func set_challenger_id(id_number):
	challenger_id = id_number


func set_challenger_name(player_name):
	$VBox/HBox/ChallengerName.set_text( player_name )


func _on_accept_challenge_pressed():
	emit_signal("accept_challange", challenger_id)


func _on_decline_challenge_pressed():
	emit_signal("decline_challange", challenger_id)
