extends KinematicBody2D

export (bool) var ui_disabled = false 
export (float) var gravity = 20.0
export (float) var friction = 0.8
export (int) var bullet_speed = 15
export (int) var hp = 10

var scrap = 0

var velocity = Vector2()
var direction = 1
var direction_string = "Right"
var moving = false
var can_dash = true
var can_jump = true
var can_shoot = true
var can_slash = true
var is_dead = false
var player_key = "p1"
var controller_id = "kb"

var slashable_bodies = []

onready var states = $state_manager
## TODO: change how game scene is assigned when implementing levels?
onready var game = null if ui_disabled else get_tree().get_root().get_child(1)
onready var bullet_scene = preload("res://scenes/Bullet.tscn")

## FOR DEBUGGING
func show_debug_label(text):
	$debug_label.text = text
	$debug_label/Timer.start()
	
func _on_debugTimer_timeout():
	$debug_label.text = ""
	
func _ready():
	states.init(self)

func _unhandled_input(event: InputEvent) -> void:
	if ui_disabled:
		return
	states.input(event)

func _physics_process(delta):
	if ui_disabled:
		return
	states.physics_process(delta)

func _process(delta: float) -> void:
	if ui_disabled:
		return
	states.process(delta)
	
	if can_shoot and Input.is_action_pressed("shoot_" + controller_id):
		shoot()
	if can_slash and Input.is_action_pressed("attack_" + controller_id):
		slash()
	
func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)

func dmg(num):
	if not is_dead:
		hp -= num
		if hp <= 0:
			$AnimationPlayer.play('death'+direction_string) ## TODO: Temp, use state
			is_dead = true
			ui_disabled = true
			g.play_sfx("player_death")
		else:
			$AnimationPlayer.play('hurt'+direction_string) 

func shoot():
	can_shoot = false
	$ShootCD.start()
	if states.current_state.name == 'dash':
		return
	var bullet = bullet_scene.instance()
	bullet.shot_by = 'player'
	bullet.global_position = global_position
	bullet.speed = bullet_speed * direction
	game.call_deferred('add_child', bullet)

func slash():
	show_debug_label('slash!')
	can_slash = false
	$SlashCD.start()
	for body in slashable_bodies:
		body.slashed(1, direction, 100) # first param is dmg, 3rd is push distance
		
func get_scrap():
	scrap += 1
	show_debug_label('scrap: ' + str(scrap))

func _on_SlashArea_body_entered(body):
	if body.is_in_group('enemies'): 
		slashable_bodies.append(body)

func _on_SlashArea_body_exited(body):
	if body.is_in_group('enemies'): 
		slashable_bodies.erase(body)

## TODO: Change attackCD timer when switching weapons
func _on_ShootCD_timeout():
	can_shoot = true

func _on_SlashCD_timeout():
	can_slash = true

