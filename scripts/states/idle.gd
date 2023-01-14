extends BaseState

export (NodePath) var jump_node
export (NodePath) var fall_node
export (NodePath) var run_node
export (NodePath) var dash_node

onready var jump_state: BaseState = get_node(jump_node)
onready var fall_state: BaseState = get_node(fall_node)
onready var run_state: BaseState = get_node(run_node)
onready var dash_state: BaseState = get_node(dash_node)

func enter() -> void:
	.enter()
	# Dashes get reset whenever the character idling again
	player.can_dash = true

func input(event: InputEvent) -> BaseState:
	if Input.is_action_just_pressed("left_kb") or Input.is_action_just_pressed("right_kb"):
		return run_state
	elif player.is_on_floor() and Input.is_action_just_pressed("jump_kb"):
		return jump_state
	elif player.can_dash and Input.is_action_just_pressed('dash_kb'):
		return dash_state
	return null

func physics_process(delta: float) -> BaseState:
	player.velocity.y += player.gravity
	player.velocity.x = lerp(player.velocity.x, 0, player.friction)
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	if !player.is_on_floor():
		return fall_state
	return null
