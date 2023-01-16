extends KinematicBody2D

var random = RandomNumberGenerator.new()

export (float) var gravity = 20.0
export (float) var friction = 0.8
export (float) var patrol_time = 2.0
export (int) var speed = 50
export (int) var chase_speed = 100
export var type: String = 'range'

export var hp = 5
export var attack_time: float = 1.0
export var start_attack_time: float = 0.5
export var bullet_speed: int = 5

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
onready var bullet_scene = preload("res://scenes/Bullet.tscn")
onready var scrap_scene = preload("res://scenes/Scrap.tscn")

func _ready():
	states.init(self)

func _physics_process(delta):
	states.physics_process(delta)

func _process(delta: float) -> void:
	states.process(delta)
	
func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)

func attack():
	$AnimationPlayer.play(name.to_lower().rstrip("0123456789")+'Attack')
	if type == 'range':
		shoot()
	else:
		target.dmg(1)

func shoot():
	var bullet = bullet_scene.instance()
	bullet.shot_by = 'enemy'
	bullet.global_position = global_position
	bullet.speed = bullet_speed * direction ## TODO: Find out why any speed less than 10 fails
	game.call_deferred('add_child', bullet)

func slashed(num, dir, dist):
	hp -= num
	if hp <= 0:
		return queue_free()
	push_direction = dir
	push_distance = dist
	states.change_state(states.get_node("pushed"))

func dmg(num):
	hp -= num
	$AnimationPlayer.play(name.to_lower().rstrip("0123456789")+'Hurt')
	if hp <= 0:
		set_collision_mask_bit(1, false)
		$AnimationPlayer.play(name.to_lower().rstrip("0123456789")+'Death')
	
func ledge_detected():
	return !left_ray.is_colliding() or !right_ray.is_colliding()
	
func drop_scrap():
	random.randomize()
	var num = random.randi_range(3, 10)
	print(str(num) + " scrap dropped")
	for n in range(num):
		var new_scrap = scrap_scene.instance()
		new_scrap.global_position = global_position
		game.add_child(new_scrap)

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


func _on_AnimationPlayer_animation_finished(anim_name):
	if 'Death' in anim_name:
		drop_scrap()
		queue_free()
