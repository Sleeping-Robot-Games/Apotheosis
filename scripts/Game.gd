extends Node2D

export var debug = false

const player_scene = preload('res://scenes/Player.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug:
		return
	spawn_players()

func spawn_players():
	var spawn_coords = Vector2(300, 250)
	for player in g.player_input_devices:
		var input_device = g.player_input_devices[player]
		if input_device != null:
			print("player: " + player)
			var player_instance = player_scene.instance()
			player_instance.player_key = player
			player_instance.controller_id = "kb" if input_device == "keyboard" else input_device.substr(4)
			player_instance.global_position = spawn_coords
			init_player_model(player_instance)
			init_player_color(player_instance)
			$Players.add_child(player_instance)
			# increment spawn coordinates for next potential player
			spawn_coords.x += 100

func init_player_model(player):
	var head_sprite = player.get_node("SpriteHolder/Head")
	#var texture_path = "res://assets/character/sprites/Head/" + g.player_models[player.player_key]
	var texture_path =  g.player_models[player.player_key]
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
