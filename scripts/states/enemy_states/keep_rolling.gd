extends BaseState

var random = RandomNumberGenerator.new()

export (NodePath) var patrol_node
export (NodePath) var chase_node
export (NodePath) var push_node

onready var patrol_state: BaseState = get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)
onready var push_state: BaseState = get_node(push_node)

var rolling_time: float = 0

func enter():
	.enter()
	
	rolling_time = actor.roll_time
	

func process(delta: float) -> BaseState:
	if actor.is_dead:
		return null
	
	if actor.is_pushed:
		return push_state
	
		
	rolling_time -= delta
	
	if rolling_time < 0 or actor.ledge_detected() or actor.is_on_wall():
		rolling_time = actor.roll_time
		
		if actor.target != null:
			return chase_state
		return patrol_state
	
	return null

func physics_process(_delta: float) -> BaseState:
	if actor.is_dead:
		return null
		
	actor.velocity.y += actor.gravity
	actor.velocity.x = actor.chase_speed * actor.direction
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)

	return null

func exit():
	.exit()
	
	actor.is_transitioning_form = true
