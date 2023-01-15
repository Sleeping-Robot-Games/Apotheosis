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
export (int) var dash_speed = 500

var current_dash_time: float = 0
var dash_direction: int = 0
var prev_player_pos

func enter() -> void:
	.enter()
	
	current_dash_time = dash_time

func input(_event: InputEvent) -> BaseState:
	return null
	
func physics_process(_delta: float) -> BaseState:
	prev_player_pos = actor.position
	actor.velocity.x =  dash_speed * actor.direction
	actor.velocity.y = 0
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)

	return null

# Track how long we've been dashing so we know when to exit
func process(delta: float) -> BaseState:
	current_dash_time -= delta
	
	if prev_player_pos != actor.position and current_dash_time > 0:
		return null

	# This makes it so the player can't repeatedly dash
	actor.can_dash = false
	
	if actor.is_on_floor():
		if Input.is_action_pressed("left_kb") or Input.is_action_pressed("right_kb"):
			return run_state
		else:
			return idle_state
	else:
		return fall_state
