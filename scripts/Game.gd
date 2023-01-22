extends Control

export (int) var spawn_distancing = 100

const player_scene = preload('res://scenes/Player.tscn')

onready var spawn_coords = $ViewportContainer/Viewport/Level/SpawnPoint.global_position
onready var players = $ViewportContainer/Viewport/Level/Players
onready var HUD = $ViewportContainer/Viewport/Level/HUD

var offscreen_positions = {
	"p1": Vector2(5,90),
	"p2": Vector2(830,90),
	"p3": Vector2(5,320),
	"p4": Vector2(830,320)
}
var num_of_players = 0

# Called when the node enters the scene tree for the first time.
func _ready():
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
			player_instance.get_node("Tutorial").show_tutorial()
			num_of_players += 1
			
			# initialize an offscreen indicator for this player
			var offscreen_scene = load("res://scenes/OffscreenIndicator.tscn")
			var offscreen_instance = offscreen_scene.instance()
			offscreen_instance.player = player_instance
			offscreen_instance.name = "offscreen" + player
			offscreen_instance.visible = false
			offscreen_instance.set_border_color()
			offscreen_instance.get_node("ViewportContainer/MiniViewport").world_2d = $ViewportContainer/Viewport.world_2d
			offscreen_instance.rect_position = offscreen_positions[player]
			add_child(offscreen_instance)
			
			# add player UI for this player
			var player_ui_scene = load("res://scenes/PlayerUI.tscn")
			var player_ui_instance = player_ui_scene.instance()
			player_ui_instance.player_key = player
			HUD.call_deferred('add_child', player_ui_instance)

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
