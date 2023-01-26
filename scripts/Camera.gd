extends Camera2D

onready var players = get_parent().get_node("Players")

var stop_tracking = false

func _process(_delta):
	if not stop_tracking:
		var middle_point = Vector2(0,0)
		var summed_positions = Vector2(0,0)
		var living_players = 0
		for player in players.get_children():
			if player.is_dead:
				continue
			living_players += 1
			summed_positions += player.global_position
		if living_players == 0:
			return
		middle_point = summed_positions / living_players
		global_position = middle_point
