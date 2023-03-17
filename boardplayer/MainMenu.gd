extends VBoxContainer


@onready var BackButton = $BackButton
@onready var MainButtons = $MainButtons
@onready var OneComputerBox = $OneComputerBox
@onready var LocalNetworkBox = $LocalNetworkBox
@onready var OverInternetBox = $OverInternetBox


func _on_back_button_pressed():
	OneComputerBox.set_visible(false)
	LocalNetworkBox.set_visible(false)
	OverInternetBox.set_visible(false)
	BackButton.set_visible(false)
	MainButtons.set_visible(true)


func _on_one_computer_pressed():
	MainButtons.set_visible(false)
	BackButton.set_visible(true)
	OneComputerBox.set_visible(true)


func _on_local_network_pressed():
	MainButtons.set_visible(false)
	BackButton.set_visible(true)
	LocalNetworkBox.set_visible(true)


func _on_over_internet_pressed():
	MainButtons.set_visible(false)
	BackButton.set_visible(true)
	OverInternetBox.set_visible(true)



