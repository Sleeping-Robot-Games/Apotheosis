extends Node

onready var game = get_tree().get_root().get_child(1)

var random = RandomNumberGenerator.new()

var player_input_devices = {
	'p1': 'keyboard',
	'p2': null,
	'p3': null,
	'p4': null,
}

# physical input duplicate entries
var ghost_inputs = ["Steam Virtual Gamepad"]

var player_colors = {
	'p1': 'color_000.png',
	'p2': null,
	'p3': null,
	'p4': null,
}

var player_models = {
	'p1': 'head_001.png',
	'p2': null,
	'p3': null,
	'p4': null,
}

func folders_in_dir(path: String) -> Array:
	var folders = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	while true:
		var folder = dir.get_next()
		if folder == "":
			break
		if not folder.begins_with("."):
			folders.append(folder)
	dir.list_dir_end()
	return folders

func files_in_dir(path: String, keyword: String = "") -> Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if keyword != "" and file.find(keyword) == -1:
			continue
		if not file.begins_with(".") and file.ends_with(".import"):
			files.append(file.replace(".import", ""))
	dir.list_dir_end()
	return files

func make_shaders_unique(sprite: Sprite):
	var mat = sprite.get_material().duplicate()
	sprite.set_material(mat)

func play_sfx(sound, dB = 0):
	var sfx_scene = load("res://scenes/SFX.tscn")
	var sfx = sfx_scene.instance()
	sfx.volume_db = dB
	
	if sound == "player_death":
		sfx.stream = load("res://assets/sfx/death_sound.mp3")
	elif sound == "player_dash":
		random.randomize()
		var n = random.randi_range(1, 2)
		sfx.stream = load("res://assets/sfx/dodge"+str(n)+".mp3")
	
	game.call_deferred('add_child', sfx)
