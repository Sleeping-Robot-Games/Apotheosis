extends Control

var join_high_pos = 90
var join_mid_pos = 100
var join_low_pos = 110

var keyboard = preload("res://assets/keyboard.png")
var controller = preload("res://assets/controller.png")

#onready var normal_stylebox = $Model/Prev.get_stylebox("normal").duplicate()
onready var focused_stylebox = $Model/Prev.get_stylebox("focus").duplicate()
onready var focusable_nodes = [[$Model/Prev, $Model/Next], [$Color/Prev, $Color/Next], [$Leave, $Ready]]
var focused_node_index = null

func _ready():
	$Player.ui_disabled = true
	remove_player()

func remove_player():
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

func add_player(player_num):
	$Name.text = player_num
	$Join.visible = false
	
	$Player.visible = true
	$InputDevice.visible = true
	$InputDevice.texture = keyboard if g.player_input_devices[player_num] == "keyboard" else controller
	if g.player_input_devices[player_num] == "keyboard":
		focused_node_index = null
	else:
		focused_node_index = Vector2(0,0)
		focus_node()
	$Model.visible = true
	$Color.visible = true
	$Name.visible = true
	$Ready.visible = true
	$Leave.visible = true
	$Checkmark.visible = false

func _input(event):
	if event.is_action_pressed('any_pad_interaction') and g.player_input_devices[$Name.text] == "joy_" + str(event.device):
		print("focusing")
		var device_num = str(event.device)
		if event.is_action_pressed("ui_up_" + device_num):
			focus_prev_row()
		elif event.is_action_pressed("ui_down_" + device_num):
			focus_next_row()
		elif event.is_action_pressed("ui_left_" + device_num):
			focus_prev_column()
		elif event.is_action_pressed("ui_right_" + device_num):
			focus_next_column()
		

func focus_prev_row():
	print("focus_prev_row")
	focused_node_index.x -= 1
	if focused_node_index.x < 0:
		focused_node_index.x = focusable_nodes.size() - 1
	focus_node()

func focus_next_row():
	print("focus_next_row")
	focused_node_index.x += 1
	if focused_node_index.x > focusable_nodes.size() - 1:
		focused_node_index.x = 0
	focus_node()

func focus_prev_column():
	print("focus_prev_column")
	focused_node_index.y -= 1
	if focused_node_index.y < 0:
		focused_node_index.y = focusable_nodes[focused_node_index.x].size() - 1
	focus_node()

func focus_next_column():
	print("focus_next_column")
	focused_node_index.y += 1
	if focused_node_index.y > focusable_nodes[focused_node_index.x].size() - 1:
		focused_node_index.y = 0
	focus_node()

func focus_node():
	# unfocus all buttons
	for row in range(focusable_nodes.size()):
		for column in range(focusable_nodes[row].size()):
			focusable_nodes[row][column].add_stylebox_override("normal", null)
	
	if focused_node_index == null:
		return
	
	# focus active button
	var focused_node = focusable_nodes[focused_node_index.x][focused_node_index.y]
	focused_node.add_stylebox_override("normal", focused_stylebox)


func _on_Tween_tween_all_completed():
	if not $Join.visible:
		return
	
	var target = join_high_pos if $Join.rect_position.y == join_low_pos else join_low_pos
	$Join/Tween.interpolate_property($Join, "rect_position:y", $Join.rect_position.y, target, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Join/Tween.start()
