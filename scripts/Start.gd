extends Control
# warning-ignore-all:return_value_discarded

onready var normal_texture = preload("res://assets/ui/button.png")
onready var focused_texture = preload("res://assets/ui/buttonhover.png")
onready var pressed_texture = preload("res://assets/ui/buttonpress.png")
onready var buttons = [$StartButton, $QuitButton]
var focused_button_index = null
var pressed_button = null

func _ready():
	g.player_input_devices["p1"] = "keyboard"
	handle_new_input()
	$Splash/SrgSplash/AnimationPlayer.play("SRG")
	$BGHolder/Apotheosis/AnimationPlayer.play("glow")
	g.play_menu_music()

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
	$StartButton.texture_normal = normal_texture
	$QuitButton.texture_normal = normal_texture
	if focused_button_index == null:
		return
	buttons[focused_button_index].texture_normal = focused_texture

func press_focused_button():
	pressed_button = buttons[focused_button_index]
	buttons[focused_button_index].texture_normal = pressed_texture
	$PressButtonTimer.start()

func _on_PressButtonTimer_timeout():
	buttons[focused_button_index].texture_normal = focused_texture
	pressed_button.emit_signal("pressed")
	pressed_button = null

func _on_StartButton_pressed():
	g.play_sfx(self, "menu_select", -10)
	get_tree().change_scene("res://scenes/PlayerSelection.tscn")

func _on_QuitButton_pressed():
	g.play_sfx(self, "menu_select", -10)
	get_tree().quit()

func _on_AnimationPlayer_animation_finished(anim_name):
	$Splash/SrgSplash.hide()
	$Splash/GwjSplash/GWJTimer.start()

func _on_GWJTimer_timeout():
	$Splash/GwjSplash.hide()

func _on_StartButton_mouse_entered():
	g.play_sfx(self, "menu_focus", -10)

func _on_QuitButton_mouse_entered():
	g.play_sfx(self, "menu_focus", -10)
