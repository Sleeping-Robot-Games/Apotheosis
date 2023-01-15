extends BaseState


export (NodePath) var idle_node
export (NodePath) var patrol_node
export (NodePath) var chase_node

onready var idle_state: BaseState = get_node(idle_node)
onready var patrol_state: BaseState =  get_node(patrol_node)
onready var chase_state: BaseState = get_node(chase_node)

var current_target

func enter() -> void:
	.enter()
	
	current_target = actor.target

func process(delta):
	return null

func physics_process(_delta: float) -> BaseState:
	## Move the actor one direction, then switch based off current_patrol_timer
	actor.velocity.y += actor.gravity
	actor.velocity.x = actor.speed * actor.direction
	actor.velocity = actor.move_and_slide(actor.velocity, Vector2.UP)
	
	return null

