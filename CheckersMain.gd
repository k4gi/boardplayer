extends Node2D


func _ready():
	get_node("%TurnDisplay").set_visible(true)


func _on_checkers_game_turn_toggled(turn):
	get_node("%TurnDisplay/Out").set_text(turn)


func _on_checkers_game_game_won(turn, score):
	get_node("%TurnDisplay").set_visible(false)
	
	get_node("%WinResult/Winner/Out").set_text(turn)
	get_node("%WinResult/Score/Out").set_text( str(score[turn]) )
	get_node("%WinResult").set_visible(true)


func _on_play_again_pressed():
	get_tree().reload_current_scene()
