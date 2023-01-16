extends BaseState


export (NodePath) var patrol_node
export (NodePath) var chase_node

onready var patrol_state: BaseState = get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)

var pushed_start = 0
var pushed_distance = 0

func enter():
	.enter()
	
	pushed_start = actor.global_position.x

func physics_process(_delta: float) -> BaseState:
	actor.velocity.x = 200 * actor.push_direction
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	
	pushed_distance = abs(actor.global_position.x) - pushed_start

	if abs(pushed_distance) > actor.push_distance:
		if actor.target != null:
			return chase_state
		return patrol_state
	return null
