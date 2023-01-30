extends Node2D


const CHECKERS_GAME = preload("res://CheckersGame.tscn")
const PLAYER = preload("res://Player.tscn")


var network_address = "localhost"
var network_port = 54321
var opponent_peer_id = null


var CheckersGame = null


@rpc
func create_game():
	get_node("%MainMenu").set_visible(false)
	%Chat/VBox/VBoxControls.set_visible(false)
	
	CheckersGame = CHECKERS_GAME.instantiate()
	CheckersGame.set_position(Vector2i(512,0))
	CheckersGame.turn_toggled.connect(_on_checkers_game_turn_toggled)
	CheckersGame.game_won.connect(_on_checkers_game_game_won)
	
	if opponent_peer_id != null:
		var remote_sender = multiplayer.get_remote_sender_id()
		if remote_sender == 0: #i must therefore be the host
			CheckersGame.i_can_move.erase("black")
		else:
			CheckersGame.i_can_move.erase("white")
	
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


func _on_host_game_pressed():
	var peer = ENetMultiplayerPeer.new()
	# Listen to peer connections, and create new player for them
	multiplayer.peer_connected.connect(_on_peer_connected)
	# Listen to peer disconnections, and destroy their players
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	peer.create_server(network_port)

	multiplayer.set_multiplayer_peer(peer)
	
	create_player(1)
	
	get_node("%MainMenu").set_visible(false)
	get_node("%Chat").set_visible(true)
	%Chat.set_mp_status()


func _on_peer_connected(id):
	create_player(id)
	opponent_peer_id = id


func _on_peer_disconnected(id):
	remove_player(id)


func create_player(id):
	var new_player = PLAYER.instantiate()
	new_player.set("peer_id", id)
	$Players.add_child(new_player, true)
	%Chat.add_message("player connected: %d" % id)
	%Chat.rpc("add_message", "player connected: %d" % id)


func remove_player(id):
	for each_player in $Players.get_children():
		if each_player.get("peer_id") == id:
			$Players.remove_child(each_player)
			each_player.queue_free()
	%Chat.add_message("player disconnected %d" % id)
	%Chat.rpc("add_message", "player disconnected %d" % id)


func _on_join_game_pressed():
	var peer = ENetMultiplayerPeer.new()
	
	peer.create_client(network_address, network_port)

	multiplayer.set_multiplayer_peer(peer)
	
	get_node("%MainMenu").set_visible(false)
	get_node("%Chat").set_visible(true)
	%Chat.set_mp_status()


func _on_start_multi_game_pressed():
	create_game()
	rpc("create_game")
