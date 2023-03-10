extends Position2D

var random = RandomNumberGenerator.new()

export var enemy_name = ""
export var tower_state = 0
export var boi_count = 3

var enemy_scene
var interval
var nearby_players = []

func _ready():
	random.randomize()
	
	interval = random.randi_range(20, 25)
	
	if enemy_name:
		$Timer.wait_time = 12 #interval
		enemy_scene = load("res://scenes/enemies/"+ enemy_name[0].to_upper() + enemy_name.substr(1,-1) +".tscn")
		$Timer.start()

func _on_Timer_timeout():
	if tower_state == g.tower_state \
		and get_tree().get_nodes_in_group(name).size() <= boi_count \
		and nearby_players.size() == 0:
		interval = interval - (g.total_kills * (interval - 2) / g.total_max_kills)
		$Timer.wait_time = interval
		var new_enemy = enemy_scene.instance()
		new_enemy.global_position = Vector2(global_position.x, global_position.y - 10)
		get_node('../../Enemies').call_deferred('add_child', new_enemy)
		new_enemy.add_to_group(name)
		new_enemy.add_to_group('tower_state_'+str(tower_state))


func _on_Area2D_body_entered(body):
	if body.is_in_group('players'):
		nearby_players.append(body)


func _on_Area2D_body_exited(body):
	if body.is_in_group('players'):
		nearby_players.erase(body)
