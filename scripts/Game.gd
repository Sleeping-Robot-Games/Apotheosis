extends Control

export var debug = false
export (int) var spawn_distancing = 100

const player_scene = preload('res://scenes/Player.tscn')

onready var spawn_coords = $ViewportContainer/Viewport/SpawnPoint.global_position
onready var players = $ViewportContainer/Viewport/Players
onready var bgm = $ViewportContainer/Viewport/BGM
onready var kill_combo = $ViewportContainer/Viewport/HUD/KillCombo
onready var killstreak_fx = $ViewportContainer/Viewport/HUD/Killstreak

# Called when the node enters the scene tree for the first time.
func _ready():
	g.game = self
	g.game_viewport = $ViewportContainer/Viewport
	spawn_players()

func spawn_players():
	var spawn_offset = 0
	for debug_player in players.get_children():
		debug_player.queue_free()
	for player in g.player_input_devices:
		var input_device = g.player_input_devices[player]
		if input_device != null:
			var player_instance = player_scene.instance()
			player_instance.player_key = player
			player_instance.controller_id = "kb" if input_device == "keyboard" else input_device.substr(4)
			player_instance.global_position = spawn_coords
			init_player_model(player_instance)
			init_player_color(player_instance)
			players.add_child(player_instance)
			# increment spawn coordinates for next potential player
			spawn_coords.x += spawn_distancing
			
			# initialize an offscreen indicator for this player
			var offscreen_scene = load("res://scenes/OffscreenIndicator.tscn")
			var offscreen_instance = offscreen_scene.instance()
			offscreen_instance.player = player_instance
			offscreen_instance.get_node("ViewportContainer/Viewport").world_2d = $ViewportContainer/Viewport.world_2d
			offscreen_instance.name = "offscreen" + player
			offscreen_instance.visible = false
			add_child(offscreen_instance)
			offscreen_instance.visible = false
			
			#player_instance.offscreen_indicator = offscreen_instance
			#offscreen_instance.show()

func init_player_model(player):
	var head_sprite = player.get_node("SpriteHolder/Head")
	var texture_path = "res://assets/character/sprites/Head/" + g.player_models[player.player_key]
	#var texture_path =  g.player_models[player.player_key]
	head_sprite.set_texture(load(texture_path))

func init_player_color(player):
	var palette_folder_path = "res://assets/character/palettes/"
	var gray_palette_path = palette_folder_path + "color_000.png"
	var player_sprites = ["Back", "BackArm", "Torso", "Head", "Legs", "TopArm"]
	for sprite in player_sprites:
		var sprite_node = player.get_node("SpriteHolder/" + sprite)
		var palette_path = palette_folder_path + g.player_colors[player.player_key]
		sprite_node.material.set_shader_param("palette_swap", load(palette_path))
		sprite_node.material.set_shader_param("greyscale_palette", load(gray_palette_path))
		g.make_shaders_unique(sprite_node)

func show_offscreen(player_key):
	#get_node("offscreen" + player_key).visible = true
	$ViewportContainer/Viewport/HUD.get_node("offscreen" + player_key).visible = true

func hide_offscreen(player_key):
	#get_node("offscreen" + player_key).visible = false
	$ViewportContainer/Viewport/HUD.get_node("offscreen" + player_key).visible = false

func activate_killstreak_mode():
	if bgm.stream.resource_path.get_file() != "cyber1.mp3":
		#print(g.new_timestamp() + "KILLSTREAK MODE ACTIVATED!! x2 Damage")
		bgm.stream = load ("res://assets/bgm/cyber1.mp3")
		bgm.play()
		killstreak_fx.visible = true
		for player in players.get_children():
			player.get_node("Killstreak").visible = true

func _on_KillstreakTimer_timeout():
	g.current_killstreak = 0
	#print(g.new_timestamp() + " Killstreak timed out resetting combo")
	kill_combo.text = "0"
	if bgm.stream.resource_path.get_file() != "background.mp3":
		#print(g.new_timestamp() + "Killstreak Mode OVER returning to normal")
		bgm.stream = load ("res://assets/bgm/background.mp3")
		bgm.play()
	killstreak_fx.visible = false
	for player in players.get_children():
		player.get_node("Killstreak").visible = false

func _on_OffCamera_body_entered(body):
	print(body.player_key + " off camera")
	if not g.offscreen_players.has(body.player_key):
		g.offscreen_players.append(body.player_key)
		get_node("offscreen" + body.player_key).visible = true
		get_node("offscreen" + body.player_key).show()

func _on_OffCamera_body_exited(body):
	print(body.player_key + " back on camera")
	g.offscreen_players.erase(body.player_key)
	get_node("offscreen" + body.player_key).hide()
	get_node("offscreen" + body.player_key).visible = false
