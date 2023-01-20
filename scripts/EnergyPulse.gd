extends Node2D

var rank = 0
var enemies = []
var bullets = []
var damage = {
	0: 1,
	1: 2,
	2: 3,
	3: 4,
	4: 5
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
	elif body.is_in_group("bullets") and body.victims == "players":
		# TODO reflect bullet if high enough rank?
		body.queue_free()

func _on_Area2D_body_exited(body):
	if body.is_in_group('enemies'): 
		enemies.erase(body)

func _on_AnimatedSprite_animation_finished():
	for enemy in enemies:
		enemy.dmg(damage[rank])
		enemy.push_distance = 150
		enemy.push_force_override = 300
		enemy.push_direction = -1 if enemy.global_position < global_position else 1
		enemy.is_pushed = true
	queue_free()
