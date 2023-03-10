extends Node
# warning-ignore-all:unused_signal

var random = RandomNumberGenerator.new()

signal shake(duration, frequency, amplitude, priority)

var killstreak_threshold = 20
var current_killstreak = 0
var tower_state = 0
var component_stage = 0
var total_kills = 0
var total_max_kills = 500
var BGM = null

var player_input_devices = {
	'p1': 'keyboard',
	'p2': null,
	'p3': null,
	'p4': null,
}

# physical input duplicate entries
var ghost_inputs = ["Steam Virtual Gamepad"]

var player_colors = {
	'p1': 'color_001.png',
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

var player_ui = {
	"p1": null,
	"p2": null,
	"p3": null,
	"p4": null
}

var ability_ranks = {
	"p1": {
		"Ability1": -1,
		"Ability2": -1,
		"Ability3": -1,
		"Ability4": -1
	},
	"p2": {
		"Ability1": -1,
		"Ability2": -1,
		"Ability3": -1,
		"Ability4": -1
	},
	"p3": {
		"Ability1": -1,
		"Ability2": -1,
		"Ability3": -1,
		"Ability4": -1
	},
	"p4": {
		"Ability1": -1,
		"Ability2": -1,
		"Ability3": -1,
		"Ability4": -1
	}
}

var offscreen_players = []

var green = Color(0.04, 0.52, 0.11, 1.0)
var red = Color(0.52, 0.04, 0.04, 1.0)
var yellow = Color(0.88, 0.77, 0.23, 1.0)

func reset_game_env():
	g.player_input_devices = {'p1':'keyboard','p2':null,'p3':null,'p4':null}
	g.player_colors = {'p1':'color_001.png','p2':null,'p3':null,'p4': null}
	g.player_models = {'p1':'head_001.png','p2': null,'p3': null,'p4': null}
	g.player_ui = {'p1':null,'p2': null,'p3': null,'p4': null}
	g.ability_ranks = {
		"p1": {"Ability1":-1,"Ability2":-1,"Ability3":-1,"Ability4":-1},
		"p2": {"Ability1":-1,"Ability2":-1,"Ability3":-1,"Ability4":-1},
		"p3": {"Ability1":-1,"Ability2":-1,"Ability3":-1,"Ability4":-1},
		"p4": {"Ability1":-1,"Ability2":-1,"Ability3":-1,"Ability4":-1},
	}
	g.offscreen_players = []

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

func play_menu_music():
	var music_player = AudioStreamPlayer.new()
	music_player.volume_db = -10
	music_player.stream = load("res://assets/sfx/menu_BGM.mp3")
	call_deferred('add_child', music_player)
	music_player.play()
	BGM = music_player
	
func stop_menu_music():
	BGM.queue_free()

func play_sfx(parent, sound, db_overide = 0):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = db_overide
	
	if sound == "player_death":
		sfx_player.stream = load("res://assets/sfx/death_sound.mp3")
	elif sound == "player_hit":
		sfx_player.stream = load("res://assets/sfx/player_getting_hit_error.mp3")
	elif sound == "player_dash":
		random.randomize()
		var n = random.randi_range(1, 2)
		sfx_player.stream = load("res://assets/sfx/dodge"+str(n)+".mp3")
	elif sound == "player_shoot":
		random.randomize()
		var n = random.randi_range(1, 4)
		sfx_player.stream = load("res://assets/sfx/small_gun_fire"+str(n)+".mp3")
	elif sound == "flamethrower_4":
		sfx_player.stream = load("res://assets/sfx/throwing_flames_4_seconds.mp3")
	elif sound == "flamethrower_5":
		sfx_player.stream = load("res://assets/sfx/throwing_flames_5_seconds.mp3")
	elif sound == "flamethrower_6":
		sfx_player.stream = load("res://assets/sfx/throwing_flames_6_seconds.mp3")
	elif sound == "flamethrower_7":
		sfx_player.stream = load("res://assets/sfx/throwing_flames_7_seconds.mp3")
	elif sound == "flamethrower_8":
		sfx_player.stream = load("res://assets/sfx/throwing_flames_8_seconds.mp3")
	elif sound == "multishot":
		sfx_player.stream = load("res://assets/sfx/multishot.mp3")
	elif sound == "barrel_shot":
		sfx_player.stream = load("res://assets/sfx/sniper.mp3")
	elif sound == "energy_pulse":
		sfx_player.stream = load("res://assets/sfx/slash.mp3")
	elif sound == "slot_machine":
		sfx_player.stream = load("res://assets/sfx/coins.mp3")
	elif sound == "chickpea_mortar_launch":
		sfx_player.stream = load("res://assets/sfx/incoming_mortar_no_explosion.mp3")
	elif sound == "chickpea_mortar_explosion":
		sfx_player.stream = load("res://assets/sfx/incoming_mortar_explosion_only.mp3")
	elif sound == "chickpea_death":
		sfx_player.stream = load("res://assets/sfx/enemy_death.mp3")
	elif sound == "chickpea_alt_death":
		sfx_player.stream = load("res://assets/sfx/chickpea_alt_death.mp3")
	elif sound == "chumba_death":
		sfx_player.stream = load("res://assets/sfx/chumba_dies.mp3")
	elif sound == "chumba_reform":
		sfx_player.stream = load("res://assets/sfx/chumba_unpacks.mp3")
	elif sound == "menu_3":
		sfx_player.stream = load("res://assets/sfx/3.mp3")
	elif sound == "menu_2":
		sfx_player.stream = load("res://assets/sfx/2.mp3")
	elif sound == "menu_1":
		sfx_player.stream = load("res://assets/sfx/1.mp3")
	elif sound == "menu_go":
		sfx_player.stream = load("res://assets/sfx/go.mp3")
	elif sound == "menu_focus":
		sfx_player.stream = load("res://assets/sfx/menu_sfx.mp3")
	elif sound == "menu_select":
		sfx_player.stream = load("res://assets/sfx/menu_select_sfx.mp3")
	elif sound == "jump_pad":
		sfx_player.stream = load("res://assets/sfx/jump_pads.mp3")
	elif sound == "tower_building":
		sfx_player.stream = load("res://assets/sfx/tower_building.mp3")
	elif sound == "healing":
		sfx_player.stream = load("res://assets/sfx/healing.mp3")
	elif sound == "picking_up_scrap":
		sfx_player.stream = load("res://assets/sfx/picking_up_scrap.mp3")
	
	sfx_player.connect("finished", sfx_player, "queue_free")

	parent.call_deferred('add_child', sfx_player)
	sfx_player.play()

func parse_enemy_name(name):
	return name.to_lower().rstrip("0123456789@").lstrip("0123456789@")

func new_timestamp():
	var tick = OS.get_ticks_msec()
	var ms = str(tick)
	ms.erase(ms.length() - 1, 1)
	var timestamp = str(tick/3600000)+":"+str(tick/60000).pad_zeros(2)+":"+str(tick/1000).pad_zeros(2)+"."+ms+"\t"
	return timestamp

func get_player_color(player_key: String, palette_x: int = 1) -> Color:
	var player_color = player_colors[player_key]
	player_color = "color_001.png" if player_color == null else player_color	
	var palette = load("res://assets/character/palettes/" + player_color)
	var data = palette.get_data()
	data.lock()
	var pixel = data.get_pixel(palette_x,0)
	data.unlock()
	return pixel
