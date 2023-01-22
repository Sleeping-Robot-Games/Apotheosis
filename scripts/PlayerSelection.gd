extends Control
# warning-ignore-all:return_value_discarded


var yellow = Color(0.88, 0.77, 0.23, 1.0)
var green = Color(0.04, 0.52, 0.11, 1.0)

var player_ready_status: Dictionary = {}
var aye_aye_captain = false
var ready_text = ["3", "2", "1", "GO!"]
var ready_sfx = ["menu_3", "menu_2", "menu_1", "menu_go"]
var ready_index = null

func _ready():
	$Camera2D.current = true
	$Boxes/Box1.add_player("p1")
	$ReadyCountdown.set("custom_colors/font_color", yellow)
	g.ability_ranks = {
	"p1": {
		"Ability1": -1,
		"Ability2": -1,
		"Ability3": -1,
		"Ability4": -1
	},
	"p2": {
		"Ability1": -1,
		"Ability2": -1,
		"Ability3": -1,
		"Ability4": -1
	},
	"p3": {
		"Ability1": -1,
		"Ability2": -1,
		"Ability3": -1,
		"Ability4": -1
	},
	"p4": {
		"Ability1": -1,
		"Ability2": -1,
		"Ability3": -1,
		"Ability4": -1
	}
}

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

func handle_player_joined(player_key):
	if not player_key:
		return
	player_ready_status[player_key] = false
	are_you_ready_kids()

func handle_player_left(player_key):
	if not player_key:
		return
	g.player_input_devices[player_key] = null
	g.player_colors[player_key] = null
	g.player_models[player_key] = null
	if player_ready_status.has(player_key):
		player_ready_status.erase(player_key)
		if player_ready_status.size() == 0:
			get_tree().change_scene("res://scenes/Start.tscn")
		else:
			are_you_ready_kids()

func handle_player_ready_changed(player_key, ready_status):
	if not player_key:
		return
	player_ready_status[player_key] = ready_status
	are_you_ready_kids()

func are_you_ready_kids():
	aye_aye_captain = true
	ready_index = null
	for p in player_ready_status:
		if not player_ready_status[p]:
			aye_aye_captain = false
	if aye_aye_captain:
		begin_ready_countdown()
	else:
		cancel_ready_countdown()

func begin_ready_countdown():
	ready_index = 0
	show_ready_text()

func show_ready_text():
	if ready_index == null:
		cancel_ready_countdown()
		return
	$ReadyCountdown.text = ready_text[ready_index]
	g.play_sfx(self, ready_sfx[ready_index])
	$ReadyCountdown.modulate.a = 1.0
	$ReadyCountdown/GrowTween.interpolate_property($ReadyCountdown, "rect_scale", Vector2(4, 4), Vector2(5, 5), 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$ReadyCountdown/GrowTween.start()

func cancel_ready_countdown():
	ready_index = null
	$ReadyCountdown.set("custom_colors/font_color", yellow)
	$ReadyCountdown.text = ""
	$ReadyCountdown.modulate.a = 1.0
	$ReadyCountdown/GrowTween.stop_all()
	$ReadyCountdown/FadeTween.stop_all()

# grow the text first
func _on_GrowTween_tween_all_completed():
	if not aye_aye_captain:
		cancel_ready_countdown()
		return
	$ReadyCountdown/FadeTween.interpolate_property($ReadyCountdown, "rect_scale", Vector2(5, 5), Vector2(4.5, 4.5), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$ReadyCountdown/FadeTween.interpolate_property($ReadyCountdown, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$ReadyCountdown/FadeTween.start()

# then fade and shrink text
func _on_FadeTween_tween_all_completed():
	if not aye_aye_captain or ready_index == null:
		cancel_ready_countdown()
		return
	if ready_index < ready_text.size() - 1:
		ready_index += 1
		if ready_index == ready_text.size() - 1:
			$ReadyCountdown.set("custom_colors/font_color", green)
		show_ready_text()
	else:
		get_tree().change_scene("res://scenes/Game.tscn")
