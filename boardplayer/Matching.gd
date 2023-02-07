extends HBoxContainer


var local_player_names = [] #local copy, downloaded from server


func refresh_player_list(player_names):
	for each_child in $Names/VBox.get_children():
		$Names/VBox.remove_child(each_child)
		each_child.queue_free()
	
	for each_id in player_names:
		var new_button = Button.new()
		new_button.set_text(str(each_id))
		$Names/VBox.add_child(new_button)



func hello():
	print("hello from server")
