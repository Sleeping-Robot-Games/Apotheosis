extends BaseState


export (NodePath) var idle_node
export (NodePath) var patrol_node
export (NodePath) var chase_node

onready var idle_state: BaseState = get_node(idle_node)
onready var patrol_state: BaseState =  get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)

func enter() -> void:
	.enter()
	print('in chase')

func process(delta):
	return null

func physics_process(_delta: float) -> BaseState:
	actor.velocity.y += actor.gravity
	#actor.velocity.x = actor.speed * actor.direction
	var direction = (actor.target.global_postiion - actor.global_position).normalized()
	
	actor.velocity = actor.move_and_slide(direction * actor.chase_speed, Vector2.UP)
	
	return null

