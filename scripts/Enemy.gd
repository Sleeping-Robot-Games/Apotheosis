extends KinematicBody2D

var random = RandomNumberGenerator.new()

export (float) var gravity = 20.0
export (float) var friction = 0.8
export (float) var patrol_time = 2.0
export (int) var speed = 50
export (int) var chase_speed = 100
export var type: String = 'range'

export var hp = 15
export var attack_time: float = 1.0
export var roll_time: float = 1.0
export var start_attack_time: float = 0
export var bullet_speed: int = 5

var velocity = Vector2()
var direction = 1 ## TODO: when this is updated in state make a signal to update animations
var direction_string = "Right"
var push_direction = 1
var push_distance = 100
var push_force_override = null
var targets = []
var target = null
var can_attack = true
var is_dead = false
var is_attacking = false
var is_pushed = false
var is_transitioning_form = false
var chumba_boi_hit = false
var max_hp = 0 # updated in ready

onready var states = $state_manager
onready var level = get_node('../../../Level')
onready var right_ray = $RayRight
onready var left_ray = $RayLeft
onready var bullet_scene = preload("res://scenes/Bullet.tscn")
onready var rigid_bullet_scene = preload("res://scenes/RigidBullet.tscn")
onready var scrap_scene = preload("res://scenes/Scrap.tscn")

func _ready():
	max_hp = hp
	set_collision_layer_bit(2, true) # Enemy
	set_collision_mask_bit(1, true) # Bullet
	set_collision_mask_bit(3, true) # Walls
	states.init(self)

func _physics_process(delta):
	states.physics_process(delta)

func _process(delta: float) -> void:
	states.process(delta)
	
func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)

func attack():
	if g.parse_enemy_name(name) != 'chumba':
		$AnimationPlayer.play(g.parse_enemy_name(name).replace('alt', '')+'Attack')
	if type == 'range':
		yield(get_tree().create_timer(0.5), "timeout")
		shoot()
	else:
		target.dmg(1)

func shoot():
	if 'Alt' in name:
		var bullet = rigid_bullet_scene.instance()
		bullet.global_position = global_position
		bullet.direction = direction
		# bullet.speed ## TODO: If we want we can adjust speed based on target distance
		level.call_deferred('add_child', bullet)
	else:
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

func get_dmg_color(num):
	var divided_hp = max_hp / 4.0
	if num >= divided_hp * 3:
		return Color(1.0, 0.0, 0.0, 1.0) # red
	elif num >= divided_hp * 2:
		return Color(0.95, 0.41, 0.03, 1.0) # orange
	elif num >= divided_hp:
		return Color(0.81, 0.75, 0.03, 1.0) # yellow
	else:
		return Color(1.0, 1.0, 1.0, 1.0) # white

func dmg(num):
	if not is_dead:
		hp -= num
		$FloatTextSpawner.float_text(str(num), get_dmg_color(num))
		var enemy_name = g.parse_enemy_name(name)
		$Sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
		$HurtRedTimer.start()
		if hp <= 0:
			g.total_kills += 1
			is_dead = true
			if g.parse_enemy_name(enemy_name) == "chickpea":
				## TODO: Make this a function
				g.play_sfx(level, "chickpea_death")
			level.increment_killstreak()
			# Disables bullet collisions
			set_collision_mask_bit(1, false)
			$AnimationPlayer.play(g.parse_enemy_name(enemy_name).replace('alt', '')+'Death')
		if enemy_name == 'chumba':
			if is_transitioning_form or states.current_state.name == 'chase' or states.current_state.name == 'keep_rolling':
				return
		if not is_dead:
			$AnimationPlayer.play(enemy_name.replace('alt', '')+'Hurt')

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
	if body.is_in_group('players') and body.hp > 0:
		target = body
		$AttackArea.monitoring = true


func _on_DetectionArea_body_exited(body):
	if body.is_in_group('players')  and body == target:
		target = null

func _on_AttackArea_body_entered(body):
	print(body)
	if body.is_in_group('players') and body == target:
		if g.parse_enemy_name(name) == 'chumba':
			chumba_boi_hit = true
			attack()
		is_attacking = true

func _on_AttackArea_body_exited(body):
	if body.is_in_group('players') :
		is_attacking = false
		chumba_boi_hit = false
		if target != null and target.hp <= 0:
			target = null
			is_attacking = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if 'Death' in anim_name:
		drop_scrap()
		queue_free()
	if g.parse_enemy_name(name) == 'chumba':
		if anim_name == 'chumbaRollingUp':
			is_transitioning_form = false
			play_animation('chumbaRolling')
		if anim_name == 'chumbaReform':
			is_transitioning_form = false
		

func _on_HurtRedTimer_timeout():
	$Sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
