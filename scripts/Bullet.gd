extends Node2D

var speed = 15

var shot_by: String = 'player'
var victims: String
var piercing = false
var damage = 1

func _ready():
	print('shot by '+ shot_by)
	if shot_by == 'player':
		victims = 'enemies'
		print('setting collision mask bits')	
		$Area2D.set_collision_mask_bit(2 , true) # enemies
		$Area2D.set_collision_mask_bit(0 , false) # player
		$Area2D.set_collision_mask_bit(7 , false) # shields
	else:
		victims = 'players'
		$Area2D.set_collision_mask_bit(2 , false)
		$Area2D.set_collision_mask_bit(0 , true)
		$Area2D.set_collision_mask_bit(7 , true)

func _physics_process(_delta):
	position.x += speed

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group(victims) and body.has_method('dmg') and body.get("is_dead") == false:
		if shot_by == "player" and g.current_killstreak >= g.killstreak_threshold:
			damage = damage * 2
		body.dmg(damage)
		if piercing == false:
			queue_free()
	elif body.is_in_group("shields"):
		# TODO if reflective, bounce bullet back
		queue_free()
	elif not body.has_method("dmg"): # aka if body is a wall
		queue_free()
