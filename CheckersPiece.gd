extends Area2D


signal pickup_piece(piece)


var follow_mouse = false
var grab_position = Vector2i.ZERO

var can_move = ["down"] # "up", "down"


func _process(_delta):
	if follow_mouse:
		mouse_following()


func _on_checkers_piece_input_event(viewport, event, shape_idx):
	if event.has_method( "get_button_index" ): #is an InputEventMouseButton?
		if not event.is_pressed():
			grab_position = get_global_position() - get_global_mouse_position()
			follow_mouse = true
			set_pickable(false)
			emit_signal("pickup_piece", self)


func mouse_following():
	set_global_position( get_global_mouse_position() + grab_position )
