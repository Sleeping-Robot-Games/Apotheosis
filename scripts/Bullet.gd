extends Node2D

var speed = 15

var shot_by: String = 'player'
var victims: String
var piercing = 0
var spawn_x = 0
var push = 0
var damage = 1
var body_found = false
var sprite = "001"
var duration = 0.5

func _ready():
	get_node(sprite).visible = true
	spawn_x = global_position.x
	prep_bullet()
	scale.x = 1 if speed < 0 else -1
	$Timer.start()

func prep_bullet():
	if shot_by == 'player':
		$Timer.wait_time = duration
		victims = 'enemies'
		$Area2D.set_collision_mask_bit(2 , true) # enemies
		$Area2D.set_collision_mask_bit(0 , false) # player
	else:
		victims = 'players'
		$Area2D.set_collision_mask_bit(2 , false)
		$Area2D.set_collision_mask_bit(0 , true)
		$Timer.wait_time = 1

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
			damage = damage + 2
		body.dmg(damage)
		if push  > 0:
			push = max(push, 4)
			var push_mods = {
				1: {"Distance": 25, "Force": 100},
				2: {"Distance": 50, "Force": 150},
				3: {"Distance": 75, "Force": 200},
				4: {"Distance": 100, "Force": 250},
			}
			body.push_distance = push_mods[push].Distance
			body.push_force_override = push_mods[push].Force
			body.push_direction = -1 if body.global_position.x < spawn_x else 1
			body.is_pushed = true
		if piercing > 0:
			piercing -= 1
		else:
			impact()
	elif not body.has_method("dmg"): # aka if body is a wall
		impact()

func impact():
	$Area2D/CollisionShape2D.set_deferred('disabled', true)
	var direction = 1 if speed < 0 else -1
	if direction == 1:
		$Impact.flip_h
	speed = 0
	$"001".hide()
	$"002".hide()
	$"003".hide()
	$"004".hide()
	$Impact.show()
	$Impact.play()

func _on_Impact_animation_finished():
	queue_free()
