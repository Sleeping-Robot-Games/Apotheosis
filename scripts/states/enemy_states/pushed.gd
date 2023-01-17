extends BaseState

export (NodePath) var patrol_node
export (NodePath) var chase_node
export (NodePath) var fall_node

onready var patrol_state: BaseState = get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)
onready var fall_state: BaseState = get_node(fall_node)

var pushed_start = 0
var pushed_distance = 0

func enter():
	.enter()
	
	pushed_start = actor.global_position.x + (actor.push_direction * 10)
	actor.can_attack = false

func physics_process(_delta: float) -> BaseState:
	if actor.is_dead:
		return null
		
	actor.velocity.y += actor.gravity
	actor.velocity.x = 200 * actor.push_direction
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	
	pushed_distance = abs(actor.global_position.x) - pushed_start
	if abs(pushed_distance) > actor.push_distance:
		actor.is_pushed = false
		
		if not actor.is_on_floor():
			return fall_state
		if actor.target != null:
			return chase_state
		return patrol_state
	if actor.is_on_wall():
		actor.is_pushed = false
		
		if actor.target != null:
			return chase_state
		return patrol_state
		
	return null


func exit():
	.exit()
	
	actor.can_attack = true
