extends Camera2D

func _on_Timer_timeout():
	init()
	
func init():
	print("init")
	get_parent().world_2d = get_tree().get_root().get_node("Game/ViewportContainer/Viewport").world_2d
	#var player = get_tree().get_root().get_node("Game/ViewportContainer/Viewport/Players/Player")
	#global_position = player.global_position
