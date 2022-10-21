extends Node2D


const CHECKERS_GAME = preload("res://CheckersGame.tscn")


var CheckersGame = null


func create_game():
	get_node("%MainMenu").set_visible(false)
	
	CheckersGame = CHECKERS_GAME.instantiate()
	CheckersGame.set_position(Vector2i(128,0))
	CheckersGame.connect("turn_toggled", _on_checkers_game_turn_toggled)
	CheckersGame.connect("game_won", _on_checkers_game_game_won)
	add_child(CheckersGame)
	
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


func _on_local_game_pressed():
	create_game()
