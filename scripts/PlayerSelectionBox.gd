extends Control
# warning-ignore-all:return_value_discarded

signal player_joined(player_key)
signal player_left(player_key)
signal player_ready_changed(player_key, ready_status)

var rng = RandomNumberGenerator.new()

var keyboard = preload("res://assets/keyboard.png")
var controller = preload("res://assets/controller.png")

onready var player_selection = get_parent().get_parent()
## TODO: custom button styleboxs
onready var focused_stylebox = $Model/Prev.get_stylebox("focus").duplicate()
onready var pressed_stylebox = $Model/Prev.get_stylebox("pressed").duplicate()
onready var buttons = [[$Model/Prev, $Model/Next], [$Color/Prev, $Color/Next], [$Leave, $Ready]]

onready var player_sprites = {
	"Back": $Player/SpriteHolder/Back,
	"BackArm": $Player/SpriteHolder/BackArm,
	"Torso": $Player/SpriteHolder/Torso,
	"Head": $Player/SpriteHolder/Head,
	"Legs": $Player/SpriteHolder/Legs,
	"TopArm": $Player/SpriteHolder/TopArm,
}

var sprite_state: Dictionary
var sprite_folder_path = "res://assets/character/sprites/"
var palette_folder_path = "res://assets/character/palettes/"

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
	
	create_random_character()

func create_random_character():
	var sprite_folders = g.folders_in_dir(sprite_folder_path)
	var palette_folders = g.folders_in_dir(palette_folder_path)
	for folder in sprite_folders:
		set_random_texture(folder)
	set_random_color()

func set_random_texture(sprite_name: String) -> void:
	var random_sprite = random_asset(sprite_folder_path + sprite_name)
	if random_sprite == "": # No assets in the folder yet continue to next folder
		return
	set_sprite_texture(sprite_name, random_sprite)

func random_asset(folder: String, keyword: String = "") -> String:
	var files: Array
	files = g.files_in_dir(folder)
	if keyword == "":
		files = g.files_in_dir(folder)
	if files.size() == 0:
		return ""
	rng.randomize()
	var random_index = rng.randi_range(0, files.size() - 1)
	return folder+"/"+files[random_index]

func set_random_color() -> void:
	var random_color
	var available_colors = []
	var all_colors = g.files_in_dir(palette_folder_path)
	for color in all_colors:
		if not '000' in color and not g.player_colors.values().has(color):
			available_colors.append(color)
	rng.randomize()
	var random_index = rng.randi_range(0, available_colors.size() - 1)
	random_color = available_colors[random_index]
	g.player_colors[player_key] = random_color
	for sprite in player_sprites.values():
		set_sprite_color(sprite, random_color)

func set_sprite_texture(sprite_name: String, texture_path: String):
	player_sprites[sprite_name].set_texture(load(texture_path))
	sprite_state[sprite_name] = texture_path

func set_sprite_color(sprite: Sprite, color_file: String) -> void:
	print("sprite")
	print(sprite)
	var palette_path = palette_folder_path + color_file
	var gray_palette_path = palette_folder_path + "color_000.png"
	sprite.material.set_shader_param("palette_swap", load(palette_path))
	sprite.material.set_shader_param("greyscale_palette", load(gray_palette_path))
	g.make_shaders_unique(sprite)

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
	var folder_path = sprite_folder_path + "Head"
	var files = g.files_in_dir(folder_path)
	var file = sprite_state["Head"].split("/")[-1]
	var cur_index = files.find(file)
	var new_index = cur_index - 1
	if new_index > len(files) - 1:
		new_index = 0
	if new_index == -1:
		new_index = len(files) -1
	var new_sprite_path = folder_path + '/' + files[new_index]
	set_sprite_texture("Head", new_sprite_path)

func _on_ModelNext_pressed():
	var folder_path = sprite_folder_path + "Head"
	var files = g.files_in_dir(folder_path)
	var file = sprite_state["Head"].split("/")[-1]
	var cur_index = files.find(file)
	var new_index = cur_index + 1
	if new_index > len(files) - 1:
		new_index = 0
	if new_index == -1:
		new_index = len(files) -1
	var new_sprite_path = folder_path + '/' + files[new_index]
	set_sprite_texture("Head", new_sprite_path)

func _on_ColorPrev_pressed():
	var available_colors = []
	var all_colors = g.files_in_dir(palette_folder_path)
	for color in all_colors:
		if color == g.player_colors[player_key]:
			available_colors.append(color)
		elif not '000' in color and not g.player_colors.values().has(color):
			available_colors.append(color)
	var cur_index = available_colors.find(g.player_colors[player_key])
	var new_index = cur_index - 1
	if new_index < 0:
		new_index = available_colors.size() - 1
	var new_color = available_colors[new_index]
	g.player_colors[player_key] = new_color
	for sprite in player_sprites.values():
		set_sprite_color(sprite, new_color)

func _on_ColorNext_pressed():
	var available_colors = []
	var all_colors = g.files_in_dir(palette_folder_path)
	for color in all_colors:
		if color == g.player_colors[player_key]:
			available_colors.append(color)
		elif not '000' in color and not g.player_colors.values().has(color):
			available_colors.append(color)
	var cur_index = available_colors.find(g.player_colors[player_key])
	var new_index = cur_index + 1
	if new_index > available_colors.size() - 1:
		new_index = 0
	var new_color = available_colors[new_index]
	g.player_colors[player_key] = new_color
	for sprite in player_sprites.values():
		set_sprite_color(sprite, new_color)

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
