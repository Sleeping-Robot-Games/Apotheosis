extends BaseState

export (NodePath) var run_node
export (NodePath) var idle_node
export (NodePath) var dash_node
export (NodePath) var jump_node

onready var run_state: BaseState = get_node(run_node)
onready var idle_state: BaseState = get_node(idle_node)
onready var dash_state: BaseState = get_node(dash_node)
onready var jump_state: BaseState = get_node(jump_node)

export (int) var max_speed = 150
export (int) var max_fall_speed= 500
export (int) var accel = 40
export (float) var jump_buffer_time = 0.1
export (float) var coyote_time = 0.2

var coyote_timer: float = 0
var jump_buffer_timer: float = 0

func enter() -> void:
	.enter()
	jump_buffer_timer = 0
	coyote_timer = coyote_time

func input(_event: InputEvent) -> BaseState:
	if actor.can_dash \
		and Input.is_action_just_pressed("dash_" + actor.controller_id) \
		and (actor.fab_menu_open == false or actor.controller_id == "kb"):
			return dash_state
	if actor.can_jump \
		and Input.is_action_just_pressed("jump_" + actor.controller_id) \
		and coyote_timer > 0:
			jump_buffer_timer = jump_buffer_time
			return jump_state
	return null
	
func process(delta: float) -> BaseState:
	jump_buffer_timer -= delta
	coyote_timer -= delta
	
	return null

func physics_process(_delta: float) -> BaseState:
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
	if actor.velocity.y > max_fall_speed:
		actor.velocity.y = max_fall_speed
		
	actor.velocity.x = clamp(actor.velocity.x, -max_speed, max_speed)
	
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)

	if actor.is_on_floor():
		if jump_buffer_timer > 0:
			return jump_state
		if actor.moving:
			return run_state
		else:
			return idle_state
	return null
