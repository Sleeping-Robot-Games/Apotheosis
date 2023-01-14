extends Control

func _ready():
	g.player_input_devices["p1"] = "keyboard"
	handle_new_input()

func _input(event):
	# keyboard
	if event is InputEventKey and event.pressed and g.player_input_devices["p1"] != "keyboard":
		g.player_input_devices["p1"] = "keyboard"
		handle_new_input()
	# mouse
	elif (event is InputEventMouseButton or event is InputEventMousevelocity) and g.player_input_devices["p1"] != "keyboard":
		g.player_input_devices["p1"] = "keyboard"
		handle_new_input()
	# joypad
	elif event.is_action_pressed('any_pad_interaction'):
		var device_name = Input.get_joy_name(event.device)
		if g.ghost_inputs.has(device_name) or g.player_input_devices["p1"] == "joy_" + str(event.device):
			return
		g.player_input_devices["p1"] = "joy_" + str(event.device)
		handle_new_input()

# player 1 input device has changed
func handle_new_input():
	if g.player_input_devices["p1"] == "keyboard":
		$InputDevice.texture = load("res://assets/keyboard.png")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var current_focus_control = get_focus_owner()
		if current_focus_control:
			current_focus_control.release_focus()
	elif "joy" in g.player_input_devices["p1"]:
		$InputDevice.texture = load("res://assets/controller.png")
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		get_node("StartButton").grab_focus()
	else:
		$InputDevice.texture = null
