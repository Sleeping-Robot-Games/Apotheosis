extends BaseState

var random = RandomNumberGenerator.new()

export (NodePath) var patrol_node
export (NodePath) var chase_node

onready var patrol_state: BaseState = get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)

var patrol_flip_time: float = 0

func enter():
	.enter()
	
	randomize()
	
	patrol_flip_time = random.randf_range(0.5, 2)

func process(delta: float) -> BaseState:
	patrol_flip_time -= delta
	
	if patrol_flip_time < 0:
		return patrol_state
		
	return null

func physics_process(_delta: float) -> BaseState:
	actor.velocity.y += actor.gravity
	actor.velocity.x = lerp(actor.velocity.x, 0, actor.friction)
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)

	return null
