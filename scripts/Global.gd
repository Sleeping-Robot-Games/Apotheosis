extends Node

var game
var game_viewport

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
	elif sound == "chickpea_death":
		sfx.stream = load("res://assets/sfx/enemy_death.mp3")
	
	game_viewport.call_deferred('add_child', sfx)

func increment_killstreak():
	#print(g.new_timestamp() + " enemy killed incrementing combo")
	current_killstreak += 1
	game_viewport.get_node("HUD/KillCombo").text = str(current_killstreak)
	if current_killstreak >= killstreak_threshold:
		game.activate_killstreak_mode()
	game_viewport.get_node("KillstreakTimer").stop()
	game_viewport.get_node("KillstreakTimer").start()

func parse_enemy_name(name):
	return name.to_lower().rstrip("0123456789@")


func new_timestamp():
	var tick = OS.get_ticks_msec()
	var ms = str(tick)
	ms.erase(ms.length() - 1, 1)
	var timestamp = str(tick/3600000)+":"+str(tick/60000).pad_zeros(2)+":"+str(tick/1000).pad_zeros(2)+"."+ms+"\t"
	return timestamp
