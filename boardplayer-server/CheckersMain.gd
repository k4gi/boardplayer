extends Node2D


var network_port = 54321


func _ready():
	var peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	peer.create_server(network_port)

	multiplayer.set_multiplayer_peer(peer)


func _on_peer_connected(id):
	%Matching.rpc("hello")


func _on_peer_disconnected(id):
	pass


@rpc(any_peer)
func create_game():
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "create_game")


@rpc(any_peer)
func set_opponent_peer_id(id):
	var remote_sender = multiplayer.get_remote_sender_id()
	if Global.opponents.has(remote_sender):
		rpc_id(Global.opponents[remote_sender], "set_opponent_peer_id", id)
