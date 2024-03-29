extends HBoxContainer


const PLAYER_LIST_ENTRY = preload("res://PlayerListEntry.tscn")
const CHALLENGE_ENTRY = preload("res://ChallengeEntry.tscn")


var local_player_names = [] #local copy, downloaded from server


@rpc("reliable")
func refresh_player_list(player_names):
	print("refreshing player list")
	print(player_names)
	for each_child in $Names/VBox.get_children():
		$Names/VBox.remove_child(each_child)
		each_child.queue_free()
	
	for each_id in player_names:
		var new_entry = PLAYER_LIST_ENTRY.instantiate()
		new_entry.set_player_id(each_id)
		if each_id == multiplayer.get_unique_id():
			new_entry.disable_challenge_button()
		else:
			new_entry.send_challenge.connect(send_challenge)
		$Names/VBox.add_child(new_entry)


@rpc("any_peer", "reliable")
func send_challenge(id_number):
	rpc_id(1, "send_challenge", id_number)


@rpc("reliable")
func receive_challenge(challenger_id):
	print("receiving challenge from %s" % challenger_id)
	var new_entry = CHALLENGE_ENTRY.instantiate()
	new_entry.set_challenger_id(challenger_id)
	new_entry.accept_challenge.connect(accept_challenge)
	new_entry.decline_challenge.connect(decline_challenge)
	$Challenges/VBox.add_child(new_entry)


@rpc("reliable")
func accept_challenge(challenger_id):
	rpc_id(1, "accept_challenge", challenger_id)


func decline_challenge(challenger_id):
	print("declining challenge")
	for each_child in $Challenges/VBox.get_children():
		if each_child.challenger_id == challenger_id:
			$Challenges/VBox.remove_child(each_child)
			each_child.queue_free()
			return
