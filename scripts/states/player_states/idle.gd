extends BaseState

export (NodePath) var jump_node
export (NodePath) var fall_node
export (NodePath) var run_node
export (NodePath) var dash_node

onready var jump_state: BaseState = get_node(jump_node)
onready var fall_state: BaseState = get_node(fall_node)
onready var run_state: BaseState = get_node(run_node)
onready var dash_state: BaseState = get_node(dash_node)

var dash_timer: float = 0

func enter() -> void:
	.enter()
	
	dash_timer = actor.dash_cd
	actor.jump_count = 0
	actor.dash_count = 0

func input(_event: InputEvent) -> BaseState:
	if Input.is_action_just_pressed("left_" + actor.controller_id) \
		or Input.is_action_just_pressed("right_" + actor.controller_id):
			return run_state
	elif actor.is_on_floor() and Input.is_action_just_pressed("jump_" + actor.controller_id) \
		and actor.fab_menu_open == false:
			return jump_state
	elif actor.dash_count < actor.mods.Dashes and Input.is_action_just_pressed("dash_" + actor.controller_id) \
		and (actor.fab_menu_open == false or actor.controller_id == "kb"):
			return dash_state
	return null

func process(_delta: float) -> BaseState:
	dash_timer -= _delta
	
	if actor.dash_count > 0 and dash_timer < 0:
		actor.dash_count = 0
	
	if actor.jump_padding:
		return jump_state
	
	return null

func physics_process(_delta: float) -> BaseState:
	actor.velocity.y += actor.gravity
	actor.velocity.x = lerp(actor.velocity.x, 0, actor.friction)
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)

	if !actor.is_on_floor():
		return fall_state
	return null
