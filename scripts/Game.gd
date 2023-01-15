extends Node2D

export var debug = false

const player_scene = preload('res://scenes/Player.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug:
		return
	# spawn players
	var spawn_coords = Vector2(300, 250)
	for player in g.player_input_devices:
		var input_device = g.player_input_devices[player]
		if input_device != null:
			var player_instance = player_scene.instance()
			player_instance.player_key = player
			player_instance.controller_id = "kb" if input_device == "keyboard" else input_device.substr(4)
			player_instance.global_position = spawn_coords
			$Players.add_child(player_instance)
			# increment spawn coordinates for next potential player
			spawn_coords.x += 100
