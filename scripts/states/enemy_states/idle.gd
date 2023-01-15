extends BaseState

export (NodePath) var patrol_node
export (NodePath) var chase_node

onready var patrol_state: BaseState = get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)


func physics_process(_delta: float) -> BaseState:
	actor.velocity.y += actor.gravity
	actor.velocity.x = lerp(actor.velocity.x, 0, actor.friction)
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)

	return null
