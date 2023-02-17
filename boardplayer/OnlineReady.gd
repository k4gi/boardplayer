extends HBoxContainer


@onready var ReadyButton = $VBox/HBoxReady/ReadyButton
@onready var StartGame = $VBox/HBoxReady/StartGame


func _on_ready_button_toggled(button_pressed):
	ReadyButton.set_disabled(true)
	rpc_id(1, "ready_button_pressed", button_pressed)


func _on_start_game_pressed():
	StartGame.set_disabled(true)
	rpc_id(1, "start_game_pressed")


@rpc("any_peer", "reliable")
func ready_button_pressed(button_pressed):
	pass #dummy


@rpc("any_peer", "reliable")
func start_game_pressed():
	pass #dummy


@rpc("reliable")
func ready_button_received():
	ReadyButton.set_disabled(false)


