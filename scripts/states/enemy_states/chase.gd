extends BaseState

export (NodePath) var idle_node
export (NodePath) var patrol_node
export (NodePath) var chase_node
export (NodePath) var fall_node

onready var idle_state: BaseState = get_node(idle_node)
onready var patrol_state: BaseState =  get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)
onready var fall_state: BaseState = get_node(fall_node)

var pacing_time = .2
var current_pacing_time
var is_pacing = false

func enter() -> void:
	.enter()
	
	is_pacing = false
	current_pacing_time = pacing_time
	actor.direction = -1 if actor.target.global_position.x < actor.global_position.x else 1
	
	if actor.is_on_wall():
		actor.global_position.x += (10 * actor.direction)
		switch_direction()

func process(delta):
	if actor.is_dead:
		return null
	if is_pacing:
		current_pacing_time -= delta
		if current_pacing_time < 0:
			current_pacing_time = pacing_time
			is_pacing = false
			switch_direction()
	if not is_pacing:
		if actor.is_on_wall():
			switch_direction()
			is_pacing = true
		if actor.ledge_detected():
			switch_direction()
			is_pacing = true
			actor.global_position.x += 12 * actor.direction
		
	return null

func physics_process(_delta: float) -> BaseState:
	if actor.is_dead:
		return null
	if is_pacing:
		## Move the actor away from the ledge or wall
		actor.velocity.y += actor.gravity
		actor.velocity.x = actor.chase_speed * actor.direction
		actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	else:
		var direction = (actor.target.global_position - actor.global_position).normalized()
		direction.y += actor.gravity
		actor.direction = -1 if actor.target.global_position.x < actor.global_position.x else 1
		actor.velocity = actor.move_and_slide(direction * actor.chase_speed, Vector2.UP)
		
	if not actor.is_on_floor():
		return fall_state
		
	return null

func switch_direction():
	# Switch direction
	actor.direction = -actor.direction if actor.direction == 1 else 1
