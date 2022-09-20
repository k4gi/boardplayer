extends Area2D


signal move_here(highlight)


func _on_move_highlight_input_event(viewport, event, shape_idx):
	if event.has_method( "get_button_index" ): #is an InputEventMouseButton?
		if not event.is_pressed():
			emit_signal("move_here", self)
