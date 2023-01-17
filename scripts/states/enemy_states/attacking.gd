extends BaseState

var random = RandomNumberGenerator.new()

export (NodePath) var patrol_node
export (NodePath) var chase_node

onready var patrol_state: BaseState =  get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)

var current_attack_time: float = 0

func enter() -> void:
	.enter()
	current_attack_time = actor.start_attack_time
	## TODO: Maybe remove this so the player doesn't get attacked right away
	# actor.attack()

func process(delta):
	if actor.is_dead:
		return null
	current_attack_time -= delta
	if current_attack_time < 0:
		actor.attack()
		current_attack_time = actor.attack_time
	if actor.target.hp <= 0:
		return patrol_state
	return null

func physics_process(_delta: float) -> BaseState:
	if actor.is_dead:
		return null
	var new_direction = -1 if actor.target.global_position.x < actor.global_position.x else 1
	if actor.direction != new_direction:
		actor.direction = new_direction
	return null
