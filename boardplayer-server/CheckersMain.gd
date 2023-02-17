extends Node


var network_port = 54321


func _ready():
	var peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	peer.create_server(network_port)

	multiplayer.set_multiplayer_peer(peer)


func _on_peer_connected(id):
	print("%s connected" % id)
	Global.player_names.append(id)
	%Matching.refresh_player_list()


func _on_peer_disconnected(id):
	print("%s disconnected" % id)
	Global.player_names.erase(id)
	%Matching.refresh_player_list()


@rpc("reliable")
func create_internet_game(opponent_colour):
	pass #dummy


@rpc("any_peer", "reliable")
func set_opponent_peer_id(id):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "set_opponent_peer_id", id)


func _on_matching_create_game(challenger_id, challengee_id):
	rpc_id(challenger_id, "create_internet_game", "black")
	rpc_id(challengee_id, "create_internet_game", "white")


