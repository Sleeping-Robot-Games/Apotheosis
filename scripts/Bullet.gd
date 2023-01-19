extends Node2D

var speed = 15

var shot_by: String = 'player'
var victims: String
var piercing = false

func _ready():
	if shot_by == 'player':
		victims = 'enemies'
		$Area2D.set_collision_mask_bit(2 , true)
		$Area2D.set_collision_mask_bit(0 , false)
	else:
		victims = 'players'
		$Area2D.set_collision_mask_bit(2 , false)
		$Area2D.set_collision_mask_bit(0 , true)


func _physics_process(_delta):
	position.x += speed


func _on_Timer_timeout():
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group(victims) and body.has_method('dmg') and body.get("is_dead") == false:
		var damage = 1
		if shot_by == "player" and g.current_killstreak >= g.killstreak_threshold:
			damage = damage * 2
		body.dmg(1)
		if piercing == false:
			queue_free()
	queue_free()
