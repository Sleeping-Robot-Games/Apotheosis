extends Position2D

export var enemy_name = ""
export var tower_state = 0

var enemy_scene
var interval = 2

func _ready():
	if enemy_name:
		$Timer.wait_time = interval
		enemy_scene = load("res://scenes/enemies/"+ enemy_name.capitalize() +".tscn")
		$Timer.start()

func _on_Timer_timeout():
	if tower_state >= g.tower_state:
		interval = 20 - (g.total_kills * 18 / 1000)
		$Timer.wait_time = interval
		var new_enemy = enemy_scene.instance()
		new_enemy.global_position = global_position
		get_node('../../Enemies').call_deferred('add_child', new_enemy)
