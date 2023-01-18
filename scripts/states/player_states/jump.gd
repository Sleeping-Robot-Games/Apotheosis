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
	actor.velocity.y = -jump_force if not actor.jump_padding else -jump_force * 2

func exit() -> void:
	actor.jump_padding = false

func input(_event: InputEvent) -> BaseState:
	if actor.can_dash and Input.is_action_just_pressed("dash_" + actor.controller_id):
		return dash_state
	return null

func physics_process(_delta: float) -> BaseState:
	actor.moving = false
	if Input.is_action_pressed("right_"  + actor.controller_id):
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
	
	if actor.velocity.y > 0:
		# This makes it so the player can't double jump from coyote_time
		actor.can_jump = false
		return fall_state

	if actor.is_on_floor():
		if actor.moving:
			return run_state
		else:
			return idle_state
	return null
