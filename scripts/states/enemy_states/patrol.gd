extends BaseState

export (NodePath) var idle_node
export (NodePath) var patrol_node
export (NodePath) var chase_node
export (NodePath) var fall_node

onready var idle_state: BaseState = get_node(idle_node)
onready var patrol_state: BaseState =  get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)
onready var fall_state: BaseState = get_node(fall_node)

export (float) var patrol_time = 1
export (int) var speed = 100

var current_patrol_time: float = 0
var direction = 1

func enter() -> void:
	.enter()
	
	current_patrol_time = patrol_time

func process(delta):
	current_patrol_time -= delta
	
	if current_patrol_time < 0:
		# Switch direction
		direction = -direction if direction == 1 else 1
		# Start patrol over
		current_patrol_time = patrol_time
	
	return null

func physics_process(_delta: float) -> BaseState:
#	if !actor.is_on_floor():
#		return fall_state

	## Move the actor one direction, then switch based off current_patrol_timer
	actor.velocity.y += actor.gravity
	actor.velocity.x = speed * direction
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	
	return null

