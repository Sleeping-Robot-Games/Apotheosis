extends Node2D

var rank = 0
var enemies = []
var rank_mods = {
	0: {"Distance": 100, "Force": 300, "Damage": 1, "Absorb": false, "Reflect": false},
	1: {"Distance": 100, "Force": 300, "Damage": 2, "Absorb": true, "Reflect": false},
	2: {"Distance": 100, "Force": 300, "Damage": 3, "Absorb": false, "Reflect": true},
	3: {"Distance": 200, "Force": 350, "Damage": 4, "Absorb": false, "Reflect": true},
	4: {"Distance": 250, "Force": 400, "Damage": 5, "Absorb": false, "Reflect": true},
}

func _ready():
	$AnimatedSprite.frame = 0
	$AnimatedSprite.playing = 1

func set_color(player_key):
	var player_color = g.get_player_color(player_key)
	$AnimatedSprite.modulate = player_color

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		enemies.append(body)

func _on_Area2D_body_exited(body):
	if body.is_in_group('enemies'): 
		enemies.erase(body)

func _on_AnimatedSprite_animation_finished():
	for enemy in enemies:
		enemy.dmg(rank_mods[rank].Damage)
		enemy.push_distance = rank_mods[rank].Distance
		enemy.push_force_override = rank_mods[rank].Force
		enemy.push_direction = -1 if enemy.global_position < global_position else 1
		enemy.is_pushed = true
	queue_free()

func _on_Area2D_area_entered(area):
	var parent = area.get_parent()
	if parent.is_in_group("bullets") and parent.victims == "players":
		if rank_mods[rank].Absorb:
			parent.queue_free()
		elif rank_mods[rank].Reflect:
			parent.reflect()
