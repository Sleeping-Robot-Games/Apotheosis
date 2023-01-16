extends KinematicBody2D

export (bool) var ui_disabled = false 
export (float) var gravity = 20.0
export (float) var friction = 0.8

var hp = 5

var velocity = Vector2()
var direction = 1
var direction_string = "Right"
var moving = false
var can_dash = true
var can_jump = true
var can_shoot = true
var can_slash = true
var player_key = "p1"
var controller_id = "kb"

var slashable_bodies = []

onready var states = $state_manager
## TODO: change how game scene is assigned when implementing levels?
onready var game = null if ui_disabled else get_tree().get_root().get_child(1)
onready var bullet_scene = preload("res://scenes/PCBullet.tscn")

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
	hp -= num
	if hp <= 0:
		$AnimationPlayer.play('death'+direction_string) ## TODO: Temp, use state
		ui_disabled = true
	else:
		$AnimationPlayer.play('hurt'+direction_string)

func shoot():
	can_shoot = false
	$ShootCD.start()
	if states.current_state.name == 'dash':
		return
	var bullet = bullet_scene.instance()
	bullet.global_position = global_position
	bullet.speed = bullet.speed * direction
	game.call_deferred('add_child', bullet)

func slash():
	can_slash = false
	$SlashCD.start()
	for body in slashable_bodies:
		body.slashed(1, direction, 100) # first param is dmg, 3rd is push distance

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
