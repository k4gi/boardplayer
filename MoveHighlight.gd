extends Area2D


signal move_here(highlight)


var is_action = true
var is_jump = false


func _on_move_highlight_input_event(viewport, event, shape_idx):
	if event.has_method( "get_button_index" ): #is an InputEventMouseButton?
		if not event.is_pressed():
			emit_signal("move_here", self)


func set_texture(texture):
	$Sprite2d.set_texture(texture)
