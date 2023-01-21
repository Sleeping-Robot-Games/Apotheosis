extends BaseState

export (NodePath) var patrol_node
export (NodePath) var chase_node
export (NodePath) var fall_node

onready var patrol_state: BaseState = get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)
onready var fall_state: BaseState = get_node(fall_node)

var pushed_start = 0
var pushed_distance = 0
var baseline_push_force = 200
var push_force = 200

func enter():
	.enter()
	
	actor.can_attack = false
	
	pushed_start = actor.global_position.x
	push_force = actor.push_force_override if actor.push_force_override > 0 else baseline_push_force

func physics_process(_delta: float) -> BaseState:
	if actor.is_dead:
		return null
		
	actor.velocity.y += actor.gravity
	actor.velocity.x = push_force * actor.push_direction
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	
	var smaller_x = min(actor.global_position.x, pushed_start)
	var bigger_x = max(actor.global_position.x, pushed_start)
	var pushed_distance = abs(abs(bigger_x) - abs(smaller_x))
	if pushed_distance > actor.push_distance:
		actor.is_pushed = false
		
		if not actor.is_on_floor():
			return fall_state
		if actor.target != null:
			return chase_state
		return patrol_state
	if actor.is_on_wall():
		var valid_wall_collision = false
		for i in actor.get_slide_count():
			var collision = actor.get_slide_collision(i)
			# pushed left and ran into wall on left
			if actor.push_direction < 0 and collision.normal.x > 0:
				valid_wall_collision = true
				break
			# or pushed right and ran into wall on right
			elif actor.push_direction > 0 and collision.normal.x < 0:
				valid_wall_collision = true
				break
		if valid_wall_collision:
			actor.is_pushed = false
		
			if actor.target != null:
				return chase_state
			return patrol_state
		
	return null


func exit():
	.exit()
	
	actor.can_attack = false
