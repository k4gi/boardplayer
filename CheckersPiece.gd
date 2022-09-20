extends Area2D


var follow_mouse = false
var grab_position = Vector2i.ZERO

var can_move = [] # "up", "down"


func _process(_delta):
	mouse_following()


func _on_checkers_piece_input_event(viewport, event, shape_idx):
	if event.has_method( "get_button_index" ): #is an InputEventMouseButton?
		print("hi!")
		if not event.is_pressed():
			grab_position = get_global_position() - get_global_mouse_position()
			follow_mouse = true
			set_pickable(false)


func mouse_following():
	if follow_mouse:
		set_global_position( get_global_mouse_position() + grab_position )
