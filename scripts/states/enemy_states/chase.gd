extends BaseState

export (NodePath) var idle_node
export (NodePath) var patrol_node
export (NodePath) var chase_node
export (NodePath) var fall_node
export (NodePath) var attacking_node
export (NodePath) var push_node
export (NodePath) var keep_rolling_node

onready var idle_state: BaseState = get_node(idle_node)
onready var patrol_state: BaseState =  get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)
onready var fall_state: BaseState = get_node(fall_node)
onready var attacking_state: BaseState = get_node(attacking_node)
onready var push_state: BaseState = get_node(push_node)
onready var keep_rolling_state: BaseState = get_node(keep_rolling_node)

var pacing_time = .2
var current_pacing_time
var is_pacing = false

func enter() -> void:
	.enter()
	
	
	is_pacing = false
	current_pacing_time = pacing_time
	actor.direction = -1 if actor.target.global_position.x < actor.global_position.x else 1
	if actor.ledge_detected():
		actor.global_position.x += (10 * actor.direction)
	if actor.is_on_wall():
		actor.global_position.x += (10 * actor.direction)
	if g.parse_enemy_name(actor.name) != 'chumba':
		switch_direction()
	

func process(delta):
	if actor.is_dead:
		return null
	
	if actor.is_pushed:
		return push_state
		
	if actor.target == null:
		return patrol_state
	
	# While chumba rolling up or out don't do shit
	if actor.is_transitioning_form:
		return null
		
	if g.parse_enemy_name(actor.name) == 'chumba':
		if actor.direction == 1:
			if actor.target.global_position.x < actor.global_position.x:
				return keep_rolling_state
		else:
			if actor.target.global_position.x > actor.global_position.x:
				return keep_rolling_state
	
	# Chumba hit while rolling, keep on going
	if actor.chumba_boi_hit:
		return keep_rolling_state
		
	if actor.is_attacking:
		return attacking_state
		
	if is_pacing:
		current_pacing_time -= delta
		if current_pacing_time < 0:
			current_pacing_time = pacing_time
			is_pacing = false
			switch_direction()
	if not is_pacing and g.parse_enemy_name(actor.name) != 'chumba':
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
		
	if actor.target == null:
		return null
			
	# While chumba rolling up or out don't do shit
	if actor.is_transitioning_form:
		return null
		
	if is_pacing:
		## Move the actor away from the ledge or wall
		actor.velocity.y += actor.gravity
		actor.velocity.x = actor.chase_speed * actor.direction
		actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	else:
		if g.parse_enemy_name(actor.name) == 'chumba':
			actor.velocity.y += actor.gravity
			actor.velocity.x = actor.chase_speed * actor.direction
			actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
		else:
			var direction = (actor.target.global_position - actor.global_position).normalized()
			direction.y += actor.gravity
			actor.direction = -1 if actor.target.global_position.x < actor.global_position.x else 1
			actor.velocity = actor.move_and_slide(direction * actor.chase_speed, Vector2.UP)
#
#		if g.parse_enemy_name(actor.name) == 'chumba':
#			actor.get_node('Sprite').flip_h = actor.direction == 1
	if not actor.is_on_floor():
		return fall_state
		
	return null

func switch_direction():
	# Switch direction
	actor.direction = -actor.direction if actor.direction == 1 else 1

