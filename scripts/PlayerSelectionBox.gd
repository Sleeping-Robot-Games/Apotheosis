extends Control
# warning-ignore-all:return_value_discarded

signal player_joined(player_key)
signal player_left(player_key)
signal player_ready_changed(player_key, ready_status)

var keyboard = preload("res://assets/keyboard.png")
var controller = preload("res://assets/controller.png")

onready var player_selection = get_parent().get_parent()
## TODO: custom button styleboxs
onready var focused_stylebox = $Model/Prev.get_stylebox("focus").duplicate()
onready var pressed_stylebox = $Model/Prev.get_stylebox("pressed").duplicate()
onready var buttons = [[$Model/Prev, $Model/Next], [$Color/Prev, $Color/Next], [$Leave, $Ready]]

var focused_button_index = null
var pressed_button = null
var player_key = null
var is_ready = null
var join_high_pos = 90
var join_mid_pos = 100
var join_low_pos = 110

func _ready():
	connect("player_joined", player_selection, "handle_player_joined")
	connect("player_left", player_selection, "handle_player_left")
	connect("player_ready_changed", player_selection, "handle_player_ready_changed")
	$Player.ui_disabled = true
	$Player/Camera2D.current = false
	remove_player()

func remove_player():
	emit_signal("player_left", player_key)
	player_key = null
	$Name.text = ""
	$Player.visible = false
	$InputDevice.visible = false
	$Model.visible = false
	$Color.visible = false
	$Name.visible = false
	$Ready.visible = false
	$Leave.visible = false
	$Checkmark.visible = false
	
	$Join.rect_position.y = join_mid_pos
	$Join.visible = true
	$Join/Tween.interpolate_property($Join, "rect_position:y", $Join.rect_position.y, join_high_pos, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Join/Tween.start()

func add_player(p_key):
	emit_signal("player_joined", p_key)
	player_key = p_key
	$Name.text = player_key
	$Join.visible = false
	
	$Player.visible = true
	$InputDevice.visible = true
	$InputDevice.texture = keyboard if g.player_input_devices[player_key] == "keyboard" else controller
	if g.player_input_devices[player_key] == "keyboard":
		focused_button_index = null
		enable_cursor()
	elif "joy_" in g.player_input_devices[player_key]:
		focused_button_index = Vector2(0,0)
		focus_button()
		disable_cursor()
	$Model.visible = true
	$Color.visible = true
	$Name.visible = true
	$Ready.visible = true
	$Leave.visible = true
	$Checkmark.visible = false

# make it so buttons interact with mouse cursor
func enable_cursor():
	for row in range(buttons.size()):
		for column in range(buttons[row].size()):
			buttons[row][column].mouse_filter = MOUSE_FILTER_STOP

# make it so buttons only interact with controller
func disable_cursor():
	for row in range(buttons.size()):
		for column in range(buttons[row].size()):
			buttons[row][column].mouse_filter = MOUSE_FILTER_IGNORE

func _input(event):
	if event.is_action_pressed('any_pad_interaction') \
		and player_key in g.player_input_devices.keys() \
		and g.player_input_devices[player_key] == "joy_" + str(event.device):
			var device_index = str(event.device)
			if event.is_action_pressed("ui_up_" + device_index):
				focus_prev_row()
			elif event.is_action_pressed("ui_down_" + device_index):
				focus_next_row()
			elif event.is_action_pressed("ui_left_" + device_index):
				focus_prev_column()
			elif event.is_action_pressed("ui_right_" + device_index):
				focus_next_column()
			elif event.is_action_pressed("ui_pad_accept"):
				press_focused_button()
		

func focus_prev_row():
	focused_button_index.x -= 1
	if focused_button_index.x < 0:
		focused_button_index.x = buttons.size() - 1
	focus_button()

func focus_next_row():
	focused_button_index.x += 1
	if focused_button_index.x > buttons.size() - 1:
		focused_button_index.x = 0
	focus_button()

func focus_prev_column():
	focused_button_index.y -= 1
	if focused_button_index.y < 0:
		focused_button_index.y = buttons[focused_button_index.x].size() - 1
	focus_button()

func focus_next_column():
	focused_button_index.y += 1
	if focused_button_index.y > buttons[focused_button_index.x].size() - 1:
		focused_button_index.y = 0
	focus_button()

func focus_button():
	# unfocus all buttons
	for row in range(buttons.size()):
		for column in range(buttons[row].size()):
			buttons[row][column].add_stylebox_override("normal", null)
	if focused_button_index == null:
		return
	# focus active button
	var focused_node = buttons[focused_button_index.x][focused_button_index.y]
	focused_node.add_stylebox_override("normal", focused_stylebox)

func press_focused_button():
	pressed_button = buttons[focused_button_index.x][focused_button_index.y]
	pressed_button.add_stylebox_override("normal", pressed_stylebox)
	$PressButtonTimer.start()

func _on_PressButtonTimer_timeout():
	pressed_button.add_stylebox_override("normal", focused_stylebox)
	pressed_button.emit_signal("pressed")
	pressed_button = null

func _on_Tween_tween_all_completed():
	if not $Join.visible:
		return
	
	var target = join_high_pos if $Join.rect_position.y == join_low_pos else join_low_pos
	$Join/Tween.interpolate_property($Join, "rect_position:y", $Join.rect_position.y, target, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Join/Tween.start()

# hide cursor if hovering over controller box, otherwise visible
func _on_Box_mouse_entered():
	if player_key in g.player_input_devices.keys():
		if g.player_input_devices[player_key] == "keyboard":
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ModelPrev_pressed():
	# TODO
	pass

func _on_ModelNext_pressed():
	# TODO
	pass

func _on_ColorPrev_pressed():
	# TODO
	pass

func _on_ColorNext_pressed():
	# TODO
	pass

func _on_Leave_pressed():
	remove_player()

func _on_Ready_pressed():
	is_ready = !is_ready
	$Checkmark.visible = is_ready
	$Ready.text = "UNREADY" if is_ready else "READY"
	$Ready.rect_size.x = 73
	emit_signal("player_ready_changed", player_key, is_ready)
	if is_ready:
		# TODO: change button to red
		return
	else:
		# TODO: change button to green
		return
