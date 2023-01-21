extends Node2D

var speed = 15

var shot_by: String = 'player'
var victims: String
var piercing = 0
var damage = 1
var body_found = false
var sprite = "001"
var duration = 0.5

func _ready():
	get_node(sprite).visible = true
	prep_bullet()
	scale.x = 1 if speed < 0 else -1
	$Timer.wait_time = duration
	$Timer.start()

func prep_bullet():
	if shot_by == 'player':
		victims = 'enemies'
		$Area2D.set_collision_mask_bit(2 , true) # enemies
		$Area2D.set_collision_mask_bit(0 , false) # player
	else:
		victims = 'players'
		$Area2D.set_collision_mask_bit(2 , false)
		$Area2D.set_collision_mask_bit(0 , true)

func reflect():
	shot_by = "player" if shot_by == "enemy" else "enemy"
	prep_bullet()
	# change bullet sprite to 002 and reverse direction
	get_node(sprite).visible = false
	sprite = "002"
	get_node(sprite).visible = true
	speed *= -1
	scale.x = 1 if speed < 0 else -1
	$Timer.stop()
	$Timer.wait_time = 5
	$Timer.start()

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
		if piercing > 0:
			piercing -= 1
		else:
			queue_free()
	elif not body.has_method("dmg"): # aka if body is a wall
		queue_free()
