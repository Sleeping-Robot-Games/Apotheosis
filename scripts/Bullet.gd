extends Node2D

var speed = 15

var shot_by: String = 'player'
var victims: String
var piercing = false
var damage = 1
var body_found = false

func _ready():
	if shot_by == 'player':
		victims = 'enemies'
		$Area2D.set_collision_mask_bit(2 , true) # enemies
		$Area2D.set_collision_mask_bit(0 , false) # player
		$Area2D.set_collision_mask_bit(7 , false) # shields
	else:
		victims = 'players'
		$Area2D.set_collision_mask_bit(2 , false)
		$Area2D.set_collision_mask_bit(0 , true)
		$Area2D.set_collision_mask_bit(7 , true)
	
	scale.x = 1 if speed < 0 else -1

func _physics_process(_delta):
	position.x += speed
	$RayCast2D.force_raycast_update()
	# Looks for enemies and if colliding with one move the bullet there to trigger area2D
	if not body_found and $RayCast2D.is_colliding(): 
		global_position = $RayCast2D.get_collision_point()

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_body_entered(body):
	body_found = true
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
