extends BaseState

export (NodePath) var fall_node
export (NodePath) var run_node
export (NodePath) var idle_node
export (NodePath) var dash_node
export (NodePath) var jump_node

onready var fall_state: BaseState = get_node(fall_node)
onready var run_state: BaseState = get_node(run_node)
onready var idle_state: BaseState = get_node(idle_node)
onready var dash_state: BaseState = get_node(dash_node)
onready var jump_state: BaseState = get_node(jump_node)

export (int) var jump_force = 300
export (int) var max_speed = 150
export (int) var accel = 40

func enter() -> void:
	# This calls the base class enter function, which is necessary here
	# to make sure the animation switches
	.enter()
	actor.jump_count += 1
	if actor.jump_count == 1:
		actor.dash_count = 0

	actor.velocity.y = -jump_force if not actor.jump_padding else -jump_force * actor.jump_force_multiplier

func exit() -> void:
	actor.jump_padding = false

func input(_event: InputEvent) -> BaseState:
	if actor.dash_count < actor.mods.Dashes and Input.is_action_just_pressed("dash_" + actor.controller_id):
		return dash_state
	elif actor.jump_count < actor.mods.Jumps and Input.is_action_just_pressed("jump_" + actor.controller_id) \
		and actor.fab_menu_open == false:
			return jump_state
	return null

func physics_process(_delta: float) -> BaseState:
	actor.moving = false
	var modded_accel = accel + (10 * actor.mods.Speed)
	if Input.is_action_pressed("right_"  + actor.controller_id):
		actor.velocity.x += modded_accel
		actor.direction = 1
		actor.moving = true
	elif Input.is_action_pressed("left_" + actor.controller_id):
		actor.direction = -1
		actor.velocity.x -= modded_accel
		actor.moving = true
	
	actor.velocity.y += actor.gravity
	
	var modded_max_speed = max_speed + (60 * actor.mods.Speed)
	actor.velocity.x = clamp(actor.velocity.x, -modded_max_speed, modded_max_speed)
	
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	
	if actor.velocity.y > 0:
		return fall_state

	if actor.is_on_floor():
		if actor.moving:
			return run_state
		else:
			return idle_state
	return null
