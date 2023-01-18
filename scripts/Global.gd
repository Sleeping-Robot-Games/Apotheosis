extends Node

var random = RandomNumberGenerator.new()

var killstreak_threshold = 5
var current_killstreak = 0

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

var offscreen_players = []

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

func play_sfx(parent, sound, db_overide = 0):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = db_overide
	
	if sound == "player_death":
		sfx_player.stream = load("res://assets/sfx/death_sound.mp3")
	elif sound == "player_dash":
		random.randomize()
		var n = random.randi_range(1, 2)
		sfx_player.stream = load("res://assets/sfx/dodge"+str(n)+".mp3")
	elif sound == "chickpea_death":
		sfx_player.stream = load("res://assets/sfx/enemy_death.mp3")
	
	sfx_player.connect("finished", sfx_player, "queue_free")

	parent.call_deferred('add_child', sfx_player)
	sfx_player.play()

func parse_enemy_name(name):
	return name.to_lower().rstrip("0123456789@")

func new_timestamp():
	var tick = OS.get_ticks_msec()
	var ms = str(tick)
	ms.erase(ms.length() - 1, 1)
	var timestamp = str(tick/3600000)+":"+str(tick/60000).pad_zeros(2)+":"+str(tick/1000).pad_zeros(2)+"."+ms+"\t"
	return timestamp
