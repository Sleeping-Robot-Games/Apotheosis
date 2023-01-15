extends KinematicBody2D

export (float) var gravity = 20.0
export (float) var friction = 0.8
export (float) var patrol_time = 2.0
export (int) var speed = 100

var velocity = Vector2()
var direction = 1
var direction_string = "Right"
var target

onready var states = $state_manager
onready var game = get_tree().get_root().get_node("Game") ## Might change when implementing levels
onready var right_ray = $RayRight
onready var left_ray = $RayLeft

func _ready():
	states.init(self)

func _physics_process(delta):
	states.physics_process(delta)

func _process(delta: float) -> void:
	states.process(delta)
	
func play_animation(anim_name):
	# $AnimationPlayer.play(anim_name)
	pass

func _on_DetectionArea_body_entered(body):
	if 'Player' in body.name:
		target = body.get_parent()
		states.change_state(states.get_node("chase"))
