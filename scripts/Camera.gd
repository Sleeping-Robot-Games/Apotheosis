extends Camera2D

onready var players = get_tree().get_root().get_child(1).get_node("Players")

func _process(delta):
	var middle_point = Vector2(0,0)
	var summed_positions = Vector2(0,0)
	for player in players.get_children():
		summed_positions += player.global_position
	middle_point = summed_positions / players.get_children().size()
	global_position = middle_point
