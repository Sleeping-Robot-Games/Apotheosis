extends BaseState

export (NodePath) var fall_node
export (NodePath) var run_node
export (NodePath) var idle_node
export (NodePath) var dash_node

onready var fall_state: BaseState = get_node(fall_node)
onready var run_state: BaseState = get_node(run_node)
onready var idle_state: BaseState = get_node(idle_node)
onready var dash_state: BaseState = get_node(dash_node)

export (int) var jump_force = 300
export (int) var max_speed = 150
export (int) var accel = 40

func enter() -> void:
	# This calls the base class enter function, which is necessary here
	# to make sure the animation switches
	.enter()
	player.velocity.y = -jump_force

func input(event: InputEvent) -> BaseState:
	if player.can_dash and Input.is_action_just_pressed('dash_kb'):
		return dash_state
	return null

func physics_process(delta: float) -> BaseState:
	player.moving = 0
	if Input.is_action_pressed("right_kb"):
		player.velocity.x += accel
		player.moving = 1
	elif Input.is_action_pressed("left_kb"):
		player.moving = -1
		player.velocity.x -= accel
	
	player.velocity.y += player.gravity
	
	player.velocity.x = clamp(player.velocity.x, -max_speed, max_speed)
	
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	if player.velocity.y > 0:
		# This makes it so the player can't double jump from coyote_time
		player.can_jump = false
		return fall_state

	if player.is_on_floor():
		if player.moving != 0:
			return run_state
		else:
			return idle_state
	return null
