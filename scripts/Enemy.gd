extends KinematicBody2D

export (float) var gravity = 20.0
export (float) var friction = 0.8

var velocity = Vector2()
var moving = 0
var direction = "Right"

onready var states = $state_manager
onready var game = get_tree().get_root().get_node("Game") ## Might change when implementing levels

func _ready():
	states.init(self)

func _physics_process(delta):
	states.physics_process(delta)

func _process(delta: float) -> void:
	states.process(delta)
	
func play_animation(anim_name):
	# $AnimationPlayer.play(anim_name)
	pass
