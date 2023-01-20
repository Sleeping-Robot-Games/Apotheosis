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
	actor.can_dash = true
	actor.can_jump = true
	
func input(_event: InputEvent) -> BaseState:
	if actor.is_on_floor() and Input.is_action_just_pressed("jump_" + actor.controller_id) and actor.fab_menu_open == false:
		return jump_state
		
	if actor.can_dash and Input.is_action_just_pressed("dash_" + actor.controller_id):
		return dash_state

	return null

func process(_delta: float) -> BaseState:
	if actor.jump_padding:
		return jump_state
	
	return null

func physics_process(_delta: float) -> BaseState:
	if !actor.is_on_floor():
		return fall_state
	
	var prev_direction = actor.direction

	actor.moving = false
	if Input.is_action_pressed("right_" + actor.controller_id):
		actor.velocity.x += accel
		actor.direction = 1
		actor.moving = true
	elif Input.is_action_pressed("left_" + actor.controller_id):
		actor.direction = -1
		actor.velocity.x -= accel
		actor.moving = true
	
	actor.velocity.y += actor.gravity
	
	actor.velocity.x = clamp(actor.velocity.x, -max_speed, max_speed)
	
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	
	if prev_direction != actor.direction:
		return run_state
	
	if not actor.moving:
		return idle_state
	
	return null
