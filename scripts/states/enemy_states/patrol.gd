extends BaseState

var random = RandomNumberGenerator.new()

export (NodePath) var idle_node
export (NodePath) var patrol_node
export (NodePath) var chase_node
export (NodePath) var fall_node

onready var idle_state: BaseState = get_node(idle_node)
onready var patrol_state: BaseState =  get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)
onready var fall_state: BaseState = get_node(fall_node)

var current_patrol_time: float = 0
var idle_flip_time: float = 0

func enter() -> void:
	.enter()
	
	randomize()
	
	current_patrol_time = actor.patrol_time
	idle_flip_time = random.randf_range(0.5, current_patrol_time)
	#actor.direction = 1

func process(delta):
	if actor.is_dead:
		return null
	current_patrol_time -= delta
	idle_flip_time -= delta
	
	if idle_flip_time < 0:
		if random.randf_range(0,1):
			switch_direction()
		return idle_state
	
	if actor.is_on_wall():
		switch_direction()
		
	if actor.ledge_detected():
		switch_direction()
		actor.global_position.x += 12 * actor.direction # this is used to make sure it doesn't flip back and forth
	
	if current_patrol_time < 0:
		switch_direction()
	
	return null

func physics_process(_delta: float) -> BaseState:
	if actor.is_dead:
		return null
	## Move the actor one direction, then switch based off current_patrol_timer
	actor.velocity.y += actor.gravity
	actor.velocity.x = actor.speed * actor.direction
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	
	if not actor.is_on_floor():
		return fall_state
		
	return null

	
func switch_direction():
	# Switch direction
	actor.direction = -actor.direction if actor.direction == 1 else 1
	# Start patrol over
	current_patrol_time = actor.patrol_time
