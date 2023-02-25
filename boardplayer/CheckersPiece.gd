extends Area2D


signal pickup_piece(piece)


var grab_position = Vector2i.ZERO

var can_move = [] # "up", "down"

var allegiance # "white" or "black"


func _on_checkers_piece_input_event(viewport, event, shape_idx):
	if event.has_method( "get_button_index" ): #is an InputEventMouseButton?
		if not event.is_pressed(): #on button release
			emit_signal("pickup_piece", self)


func set_texture(texture):
	$Sprite2d.set_texture(texture)


func get_texture():
	return $Sprite2d.get_texture()
