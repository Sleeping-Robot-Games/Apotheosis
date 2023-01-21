extends Position2D

var random = RandomNumberGenerator.new()

export var enemy_name = ""
export var tower_state = 0

var enemy_scene
var interval
var my_bois = []

func _ready():
	return
	random.randomize()
	
	interval = random.randi_range(20, 25)
	
	if enemy_name:
		$Timer.wait_time = 1
		enemy_scene = load("res://scenes/enemies/"+ enemy_name[0].to_upper() + enemy_name.substr(1,-1) +".tscn")
		$Timer.start()

func _on_Timer_timeout():
	if tower_state >= g.tower_state and my_bois.size() < 5:
		interval = interval - (g.total_kills * (interval - 2) / 1000)
		$Timer.wait_time = interval
		var new_enemy = enemy_scene.instance()
		new_enemy.global_position = Vector2(global_position.x, global_position.y - 10)
		get_node('../../Enemies').call_deferred('add_child', new_enemy)
		my_bois.append(new_enemy)
