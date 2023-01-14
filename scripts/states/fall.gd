extends BaseState

export (int) var max_speed = 150
export (int) var max_fall_speed= 500
export (int) var accel = 40

func physics_process(delta: float) -> int:
	player.moving = 0
	if Input.is_action_pressed("right_kb"):
		player.velocity.x += accel
		player.moving = 1
	elif Input.is_action_pressed("left_kb"):
		player.moving = -1
		player.velocity.x -= accel
	
	player.velocity.y += player.gravity
	if player.velocity.y > max_fall_speed:
		player.velocity.y = max_fall_speed
		
	player.velocity.x = clamp(player.velocity.x, -max_speed, max_speed)
	
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	if player.is_on_floor():
		if player.moving != 0:
			return State.Run
		else:
			return State.Idle
	return State.Null
