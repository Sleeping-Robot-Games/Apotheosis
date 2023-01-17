extends BaseState

export (NodePath) var patrol_node
export (NodePath) var chase_node

onready var patrol_state: BaseState = get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)

export (int) var max_fall_speed= 500

func enter():
	.enter()
	
	actor.can_attack = false
	
func physics_process(_delta: float) -> BaseState:
	if actor.is_dead:
		return null
	actor.velocity.y += actor.gravity
	if actor.velocity.y > max_fall_speed:
		actor.velocity.y = max_fall_speed
		
	#actor.velocity.x = clamp(actor.velocity.x, -actor.speed, actor.speed)
	
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)

	if actor.is_on_floor():
		if actor.target != null:
			return chase_state
		return patrol_state
	return null

func exit():
	.exit()
	
	actor.can_attack = true
