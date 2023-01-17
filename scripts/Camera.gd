extends Camera2D

onready var player = get_tree().get_root().get_child(1).get_node("Players").get_child(0)

func _process(delta):
	global_position = player.global_position
