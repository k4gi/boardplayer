extends Area2D


signal move_here(highlight)


var is_action = true

var is_taking_piece = null #Vector2i grid position


func _on_move_highlight_input_event(_viewport, event, _shape_idx):
	if event.has_method( "get_button_index" ): #is an InputEventMouseButton?
		if not event.is_pressed():
			emit_signal("move_here", self)


func set_texture(texture):
	$Sprite2d.set_texture(texture)
