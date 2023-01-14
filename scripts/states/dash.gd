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

export (float) var dash_time = 0.4

var current_dash_time: float = 0
var dash_direction: int = 0

func enter() -> void:
	.enter()
	
	current_dash_time = dash_time

func input(event: InputEvent) -> BaseState:
	return null
	
func physics_process(delta: float) -> BaseState:
	player.velocity.x =  500 if player.direction == 'Right' else -500
	player.velocity.y = 0
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	return null

# Track how long we've been dashing so we know when to exit
func process(delta: float) -> BaseState:
	current_dash_time -= delta
	
	if current_dash_time > 0:
		return null

	# This makes it so the player can't repeatedly dash
	player.can_dash = false
	
	if player.is_on_floor():
		if Input.is_action_pressed("left_kb") or Input.is_action_pressed("right_kb"):
			return run_state
		else:
			return idle_state
	else:
		return fall_state
