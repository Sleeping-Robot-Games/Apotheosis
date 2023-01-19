extends Control

var player = null

func _process(_delta):
	if visible and player != null:
		$ViewportContainer/MiniViewport/OffscreenCamera.global_position = player.global_position

func set_border_color():
	var player_color = g.get_player_color(player.player_key)
	$Border.modulate = player_color
	$BG.modulate = player_color
	$BG.modulate.a = 0.25
