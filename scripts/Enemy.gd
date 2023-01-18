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
var targets = []
var target = null
var can_attack = true
var is_dead = false
var is_attacking = false
var is_pushed = false

onready var states = $state_manager
## Might change when implementing levels
onready var level = get_node('../../../Level')
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
	$AnimationPlayer.play(g.parse_enemy_name(name)+'Attack')
	if type == 'range':
		shoot()
	else:
		target.dmg(1)

func shoot():
	var bullet = bullet_scene.instance()
	bullet.shot_by = 'enemy'
	bullet.global_position = global_position
	bullet.speed = bullet_speed * direction ## TODO: Find out why any speed less than 10 fails
	level.call_deferred('add_child', bullet)

func pushed(num, dir, dist):
	dmg(num)
	push_direction = dir
	push_distance = dist
	is_pushed = true

func dmg(num):
	if not is_dead:
		hp -= num
		var enemy_name = g.parse_enemy_name(name)
		$AnimationPlayer.play(enemy_name+'Hurt')
		$Sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
		$HurtRedTimer.start()
		if hp <= 0:
			is_dead = true
			if g.parse_enemy_name(enemy_name) == "chickpea":
				## TODO: Make this a function
				g.play_sfx(owner, "chickpea_death")
			level.increment_killstreak()
			# Disables bullet collisions
			set_collision_mask_bit(1, false)
			$AnimationPlayer.play(g.parse_enemy_name(enemy_name)+'Death')
	
func ledge_detected():
	return !left_ray.is_colliding() or !right_ray.is_colliding()
	
func drop_scrap():
	random.randomize()
	var num = random.randi_range(3, 10)
	print(str(num) + " scrap dropped")
	for n in range(num):
		var new_scrap = scrap_scene.instance()
		new_scrap.global_position = global_position
		level.add_child(new_scrap)

func _on_DetectionArea_body_entered(body):
	## TODO: What to do if a new player enters the area?
	if can_attack:
		if body.is_in_group('players') and body.hp > 0:
			# targets.append(body)
			target = body
			#states.change_state(states.get_node("chase"))

func _on_DetectionArea_body_exited(body):
	if body.is_in_group('players')  and body == target:
		target = null
		# states.change_state(states.get_node("patrol"))

func _on_AttackArea_body_entered(body):
	if can_attack:
		if body.is_in_group('players') and body == target:
			# states.change_state(states.get_node("attacking"))
			is_attacking = true

func _on_AttackArea_body_exited(body):
	if body.is_in_group('players') :
		is_attacking = false
		if target != null and target.hp <= 0:
			target = null
			is_attacking = false
			# states.change_state(states.get_node("patrol"))
		#elif not states.current_state.name in ['pushed', 'fall']:

			#states.change_state(states.get_node("chase"))

func _on_AnimationPlayer_animation_finished(anim_name):
	if 'Death' in anim_name:
		drop_scrap()
		queue_free()

func _on_HurtRedTimer_timeout():
	$Sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
