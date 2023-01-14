extends BaseState

func input(event: InputEvent) -> int:
	if Input.is_action_just_pressed("left_kb") or Input.is_action_just_pressed("right_kb"):
		return State.Run
	elif player.is_on_floor() and Input.is_action_just_pressed("jump_kb"):
		return State.Jump
	return State.Null

func physics_process(delta: float) -> int:
	player.velocity.y += player.gravity
	
	player.velocity.x = lerp(player.velocity.x, 0, player.friction)
	
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	if !player.is_on_floor():
		return State.Fall
	return State.Null
