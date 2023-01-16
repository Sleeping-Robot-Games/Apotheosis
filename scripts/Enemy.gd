extends KinematicBody2D

export (float) var gravity = 20.0
export (float) var friction = 0.8
export (float) var patrol_time = 2.0
export (int) var speed = 50
export (int) var chase_speed = 100
export var type: String = 'range'

export var hp = 5

var velocity = Vector2()
var direction = 1 ## TODO: when this is updated in state make a signal to update animations
var push_direction = 1
var direction_string = "Right"
var push_distance = 100
var target = null
var can_attack = true

onready var states = $state_manager
## Might change when implementing levels
onready var game = get_tree().get_root().get_child(1)
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

func attack():
	print('enemy attacking')
	target.dmg(1)
	$AnimationPlayer.play("attack_test")

func slashed(num, dir, dist):
	hp -= num
	if hp <= 0:
		return queue_free()
	push_direction = dir
	push_distance = dist
	states.change_state(states.get_node("pushed"))

func dmg(num):
	hp -= num
	$AnimationPlayer.play("dmg_test")
	if hp <= 0:
		queue_free() # TODO: Use state
	
func ledge_detected():
	return !left_ray.is_colliding() or !right_ray.is_colliding()

func _on_DetectionArea_body_entered(body):
	## TODO: What to do if a new player enters the area?
	if can_attack:
		if body.is_in_group('players') and body.hp > 0:
			target = body
			states.change_state(states.get_node("chase"))

func _on_DetectionArea_body_exited(body):
	if body.is_in_group('players')  and body == target:
		target = null
		states.change_state(states.get_node("patrol"))

func _on_AttackArea_body_entered(body):
	if can_attack:
		if body.is_in_group('players') and body == target:
			states.change_state(states.get_node("attacking"))

func _on_AttackArea_body_exited(body):
	if body.is_in_group('players') :
		if target == null or target.hp <= 0:
			target = null
			states.change_state(states.get_node("patrol"))
		elif not states.current_state.name in ['pushed', 'fall']:
			states.change_state(states.get_node("chase"))
