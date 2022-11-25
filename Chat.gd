extends ScrollContainer


func add_message(message: String):
	var new_label = Label.new()
	new_label.set_text(message)
	$VBoxContainer.add_child(new_label)
