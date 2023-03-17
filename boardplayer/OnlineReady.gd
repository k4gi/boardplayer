extends HBoxContainer


@onready var ReadyButton = $VBox/HBoxReady/ReadyButton
@onready var StartGame = $VBox/HBoxReady/StartGame


@rpc("any_peer", "reliable")
func ready_button_pressed(_button_pressed):
	pass #dummy


@rpc("any_peer", "reliable")
func start_game_pressed():
	pass #dummy


@rpc("reliable")
func ready_button_received():
	ReadyButton.set_disabled(false)


@rpc("reliable")
func start_button_disable(boolean: bool):
	StartGame.set_disabled(boolean)


@rpc("reliable")
func hide_online_ready():
	set_visible(false)


func _on_ready_button_toggled(button_pressed):
	print("ready_button_toggled")
	ReadyButton.set_disabled(true)
	rpc("ready_button_pressed", button_pressed)


func _on_start_game_pressed():
	StartGame.set_disabled(true)
	rpc_id(1, "start_game_pressed")
