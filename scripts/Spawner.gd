extends Position2D

export var enemy_name = ""

var enemy_scene
var interval = 10

func _ready():
	if enemy_name:
		$Timer.wait_time = interval
		enemy_scene = load("res://scenes/enemies/"+ enemy_name +".tscn")
		$Timer.start()

func _on_Timer_timeout():
	$Timer.wait_time = interval
	var new_enemy = enemy_scene.instance()
	new_enemy.global_position = global_position
	get_node('../../Enemies').call_deferred('add_child', new_enemy)
