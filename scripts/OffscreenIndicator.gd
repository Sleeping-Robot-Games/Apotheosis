extends Control

var player = null

func _process(_delta):
	if visible and player != null:
		$ViewportContainer/MiniViewport/OffscreenCamera.global_position = player.global_position

func set_border_color():
	var player_color = g.player_colors[player.player_key]
	var palette = load("res://assets/character/palettes/" + player_color)
	var data = palette.get_data()
	data.lock()
	var pixel = data.get_pixel(1,0)
	data.unlock()
	$Border.modulate = pixel
	$BG.modulate = pixel
	$BG.modulate.a = 0.25
