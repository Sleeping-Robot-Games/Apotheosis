extends BaseState

export (NodePath) var idle_node
export (NodePath) var jump_node
export (NodePath) var fall_node
export (NodePath) var run_node
export (NodePath) var dash_node

onready var idle_state: BaseState = get_node(idle_node)
onready var jump_state: BaseState = get_node(jump_node)
onready var fall_state: BaseState = get_node(fall_node)
onready var run_state: BaseState = get_node(run_node)
onready var dash_state: BaseState = get_node(dash_node)

export (int) var max_speed = 150
export (int) var accel = 40

func enter() -> void:
	.enter()
	# Dashes get reset whenever the character starts running again
	player.can_dash = true
	player.can_jump = true
	
func input(_event: InputEvent) -> BaseState:
	if player.is_on_floor() and Input.is_action_just_pressed("jump_kb"):
		return jump_state
		
	if player.can_dash and Input.is_action_just_pressed("dash_kb"):
		return dash_state

	return null

func physics_process(_delta: float) -> BaseState:
	if !player.is_on_floor():
		return fall_state

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
	
	if player.moving == 0:
		return idle_state

	return run_state
