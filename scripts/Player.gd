extends KinematicBody2D

export (bool) var ui_disabled = false 
export (float) var gravity = 20.0
export (float) var friction = 0.8

var velocity = Vector2()
var moving = 0
var direction = "Right"
var can_dash = true
var can_jump = true
var can_shoot = true

onready var states = $state_manager
onready var game = get_tree().get_root().get_node("Game") ## Might change when implementing levels
onready var bullet_scene = preload("res://scenes/PCBullet.tscn")

func _ready():
	states.init(self)
	
func _unhandled_input(event: InputEvent) -> void:
	if ui_disabled:
		return
	states.input(event)
	
	if can_shoot and Input.is_action_pressed("attack_kb"):
		shoot()
	
func _physics_process(delta):
	if ui_disabled:
		return
	states.physics_process(delta)

func _process(delta: float) -> void:
	if ui_disabled:
		return
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

func shoot():
	if states.current_state.name == 'dash':
		return

	var bullet = bullet_scene.instance()
	bullet.global_position = global_position
	bullet.speed = bullet.speed * -1 if direction == 'Left' else bullet.speed
	game.call_deferred('add_child', bullet)
	can_shoot = false
	$AttackCD.start()

## TODO: Change attackCD timer when switching weapons
func _on_AttackCD_timeout():
	can_shoot = true
