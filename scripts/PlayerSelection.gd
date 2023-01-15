extends Control

func _ready():
	print("adding player p1")
	$Boxes/Box1.add_player("p1")

func _input(event):
	# skip checking for new players if no empty slots left
	if not g.player_input_devices.values().has(null):
		return
	# keyboard
	if event is InputEventKey and event.pressed and not g.player_input_devices.values().has("keyboard"):
		handle_new_input("keyboard")
	# mouse button
	elif event is InputEventMouseButton and not g.player_input_devices.values().has("keyboard"):
		handle_new_input("keyboard")
	# joypad
	elif event.is_action_pressed('any_pad_interaction'):
		var device_name = Input.get_joy_name(event.device)
		var device_id = "joy_" + str(event.device)
		# skip if ghost input or if input is already assigned to a player
		if g.ghost_inputs.has(device_name) or g.player_input_devices.values().has(device_id):
			return
		handle_new_input(device_id)

# new input device has joined the game
func handle_new_input(input_device):
	for i in range(0, g.player_input_devices.values().size()):
		var player_key = "p" + str(i + 1)
		if g.player_input_devices[player_key] == null:
			g.player_input_devices[player_key] = input_device
			get_node("Boxes/Box" + str(i + 1)).add_player(player_key)
			break
