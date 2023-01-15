extends Control
# warning-ignore-all:return_value_discarded

## TODO: custom button styleboxs
onready var focused_stylebox = $StartButton.get_stylebox("focus").duplicate()
onready var pressed_stylebox = $StartButton.get_stylebox("pressed").duplicate()
onready var buttons = [$StartButton, $QuitButton]
var focused_button_index = null
var pressed_button = null

func _ready():
	g.player_input_devices["p1"] = "keyboard"
	handle_new_input()

func _input(event):
	# keyboard
	if event is InputEventKey and event.pressed and g.player_input_devices["p1"] != "keyboard":
		g.player_input_devices["p1"] = "keyboard"
		handle_new_input()
	# mouse
	elif (event is InputEventMouseButton or event is InputEventMouseMotion) and g.player_input_devices["p1"] != "keyboard":
		g.player_input_devices["p1"] = "keyboard"
		handle_new_input()
	# joypad
	elif event.is_action_pressed('any_pad_interaction'):
		var device_name = Input.get_joy_name(event.device)
		var device_id = "joy_" + str(event.device)
		if g.ghost_inputs.has(device_name):
			return
		elif g.player_input_devices["p1"] == device_id:
			var device_index = str(event.device)
			if event.is_action_pressed("ui_up_" + device_index) or event.is_action_pressed("ui_left_" + device_index):
				focus_prev()
			elif event.is_action_pressed("ui_down_" + device_index) or event.is_action_pressed("ui_right_" + device_index):
				focus_next()
			elif event.is_action_pressed("ui_pad_accept"):
				press_focused_button()
			return
		g.player_input_devices["p1"] = device_id
		handle_new_input()

# player 1 input device has changed
func handle_new_input():
	if g.player_input_devices["p1"] == "keyboard":
		$InputDevice.texture = load("res://assets/keyboard.png")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		focused_button_index = null
		focus_button()
	elif "joy_" in g.player_input_devices["p1"]:
		$InputDevice.texture = load("res://assets/controller.png")
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		focused_button_index = 0
		focus_button()

func focus_prev():
	focused_button_index -= 1
	if focused_button_index < 0:
		focused_button_index = buttons.size() - 1
	focus_button()

func focus_next():
	focused_button_index += 1
	if focused_button_index > buttons.size() - 1:
		focused_button_index = 0
	focus_button()

func focus_button():
	# unfocus all buttons
	for button in buttons:
		button.add_stylebox_override("normal", null)
	if focused_button_index == null:
		return
	buttons[focused_button_index].add_stylebox_override("normal", focused_stylebox)

func press_focused_button():
	pressed_button = buttons[focused_button_index]
	pressed_button.add_stylebox_override("normal", pressed_stylebox)
	$PressButtonTimer.start()

func _on_PressButtonTimer_timeout():
	pressed_button.add_stylebox_override("normal", focused_stylebox)
	pressed_button.emit_signal("pressed")
	pressed_button = null

func _on_StartButton_pressed():
	get_tree().change_scene("res://scenes/PlayerSelection.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
