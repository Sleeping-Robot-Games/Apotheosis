extends KinematicBody2D

export (float) var gravity = 20
export (float) var friction = 0.8

var velocity = Vector2()
var moving = 0
var direction = "Right"
var can_dash = true
var can_jump = true

onready var states = $state_manager

func _ready():
	states.init(self)
	
func _unhandled_input(event: InputEvent) -> void:
	states.input(event)
	
func _physics_process(delta):
	states.physics_process(delta)

func _process(delta: float) -> void:
	states.process(delta)
	
func play_animation(anim_name):
	set_arms_indices()
	$AnimationPlayer.play(anim_name)

func set_arms_indices():
	if direction == 'Right':
		# Move right arm on top
		$SpriteHolder.move_child($SpriteHolder/Right, 0)
		$SpriteHolder.move_child($SpriteHolder/Left, 4)
	else:
		# Move Left arm on top
		$SpriteHolder.move_child($SpriteHolder/Left, 0)
		$SpriteHolder.move_child($SpriteHolder/Right, 4)
