extends BaseState

var random = RandomNumberGenerator.new()

export (NodePath) var patrol_node
export (NodePath) var chase_node
export (NodePath) var push_node

onready var patrol_state: BaseState =  get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)
onready var push_state: BaseState = get_node(push_node)

var current_attack_time: float = 0
var prev_direction

func enter() -> void:
	.enter()
	current_attack_time = actor.start_attack_time

func process(delta):
	if actor.is_dead:
		return null
	
	if actor.target and actor.target.is_dead:
		return patrol_state
	
	if actor.is_pushed:
		return push_state
		
	if not actor.is_attacking:
		return patrol_state
	
	current_attack_time -= delta
	if current_attack_time < 0:
		actor.call_deferred('attack')
		current_attack_time = actor.attack_time
		
	if actor.target.hp <= 0:
		return patrol_state
		
	return null

func physics_process(_delta: float) -> BaseState:
	if actor.is_dead:
		return null
		
	if actor.target == null:
		return patrol_state
		
	prev_direction = actor.direction
	actor.direction = -1 if actor.target.global_position.x < actor.global_position.x else 1
	if prev_direction != actor.direction:
		actor.get_node('Sprite').flip_h = actor.direction == 1

	return null
