extends Node2D


const CHECKERS_GAME = preload("res://CheckersGame.tscn")
const PLAYER = preload("res://Player.tscn")


var network_address = "localhost"
var network_port = 54321
#var internet_address = "51.161.152.131"
var internet_address = "localhost"
var internet_port = 54321

var opponent_peer_id = null


var CheckersGame = null


func _ready():
	%IPAddressEntry.set_text( str(network_address) )
	%IPPortEntry.set_text( str(network_port) )
	%HostPortEntry.set_text( str(network_port) )

@rpc
func create_game():
	get_node("%MainMenu").set_visible(false)
	%Chat/VBox/VBoxControls.set_visible(false)
	
	CheckersGame = CHECKERS_GAME.instantiate()
	CheckersGame.set_position(Vector2i(512,0))
	CheckersGame.turn_toggled.connect(_on_checkers_game_turn_toggled)
	CheckersGame.game_won.connect(_on_checkers_game_game_won)
	
	if opponent_peer_id != null: #we're doing network multiplayer
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
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	network_port = int( %HostPortEntry.get_text() )
	
	peer.create_server(network_port)

	multiplayer.set_multiplayer_peer(peer)
	
	get_node("%MainMenu").set_visible(false)
	get_node("%Chat").set_visible(true)
	%Chat.set_mp_status()


func _on_peer_connected(id):
	opponent_peer_id = id
	rpc("set_opponent_peer_id", multiplayer.get_multiplayer_peer()) #should be 1? cause we're the host?


@rpc
func set_opponent_peer_id(id):
	opponent_peer_id = id


func _on_peer_disconnected(id):
	pass


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
	
	network_address = %IPAddressEntry.get_text()
	network_port = int( %IPPortEntry.get_text() )
	
	peer.create_client(network_address, network_port)

	multiplayer.set_multiplayer_peer(peer)
	
	get_node("%MainMenu").set_visible(false)
	get_node("%Chat").set_visible(true)
	%Chat.set_mp_status()


func _on_start_multi_game_pressed():
	create_game()
	rpc("create_game")


func _on_online_game_pressed():
	var peer = ENetMultiplayerPeer.new()
	
	peer.create_client(internet_address, internet_port)
	
	multiplayer.set_multiplayer_peer(peer)
	
	%MainMenu.set_visible(false)
	%Matching.set_visible(true)


@rpc
func hello():
	%Matching.hello()

@rpc
func refresh_player_list(player_names):
	%Matching.refresh_player_list(player_names)
