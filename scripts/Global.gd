extends Node


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
