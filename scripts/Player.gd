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
var prev_anim = ""
var jump_padding = false

var close_range_bodies = []
var upgrade_cost = [100, 200, 300, 400, 500]
var current_upgrade = 0
var can_fabricate = false
var fabricating_progress = 0
var upgrades = {
	'Tank': [],
	'Barrel': [],
	'Scope': [],
	'Handle': []
}

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

func _input(event):
	if can_fabricate and event.is_action_pressed("fab_" + str(controller_id)):
		show_fabricate_icon(true)
	elif can_fabricate and event.is_action_released("fab_" + str(controller_id)):
		show_fabricate_icon(false)

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
	
func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)

func dmg(num):
	if not is_dead:
		hp -= num
		for sprite in $SpriteHolder.get_children():
			sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
		$HurtRedTimer.start()
		if hp <= 0:
			$AnimationPlayer.play('death'+direction_string) ## TODO: Temp, use state
			is_dead = true
			ui_disabled = true
			g.play_sfx("player_death")
		else:
			if states.current_state.name == 'run':
				$AnimationPlayer.play('runHurt'+direction_string) 
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

func apply_pierce():
	## TODO: Check upgrades to apply
	pass

func apply_range(num):
	## TODO: Check upgrades to apply
	pass
	
func apply_close_range():
	## TODO: Check upgrades to apply
	pass

func apply_push(num):
	## TODO: Check upgrades to apply
	pass

func get_scrap():
	scrap += 10
	show_debug_label('scrap: ' + str(scrap))
	if upgrade_cost.size() > 0 and scrap >= upgrade_cost[0]:
		can_fabricate = true
		show_fabricate_icon()

func show_fabricate_icon(var pressed = false):
	var btn = "F" if controller_id == "kb" else "Y"
	var num = "_002.png" if pressed else "_001.png"
	$Fabricate.visible = true
	$Fabricate/Label.visible = !pressed
	$Fabricate/Progress.visible = pressed
	$Fabricate/Icon.texture = load("res://assets/" + btn + num)
	$Fabricate/Icon.visible = true
	if pressed:## TODO: Match time to fabricate animation?
		$Fabricate/Tween.interpolate_property($Fabricate/Progress, "value", 0, 100, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Fabricate/Tween.start()
	else:
		$Fabricate/Tween.stop_all()
		fabricating_progress = 0

func random_upgrade():
	show_debug_label("UPGRADE INSTALLED")
	scrap -= upgrade_cost[0]
	if current_upgrade == 0:
		# TODO
		pass
	elif current_upgrade == 1:
		# TODO
		pass
	elif current_upgrade == 2:
		# TODO
		pass
	elif current_upgrade == 3:
		# TODO
		pass
	elif current_upgrade == 4:
		# TODO
		pass
	
	current_upgrade += 1
	upgrade_cost.remove(0)
	can_fabricate = false
	if upgrade_cost.size() > 0 and scrap >= upgrade_cost[0]:
		can_fabricate = true
		show_fabricate_icon()
		
func flip_close_range():
	$CloseRangeArea.rotation_degrees = 180 if direction == 1 else 0

func _on_FabricateTween_tween_all_completed():
	$Fabricate.visible = false
	can_fabricate = false
	fabricating_progress = 0
	random_upgrade()

func _on_CloseRangeArea_body_entered(body):
	if body.is_in_group('enemies'): 
		close_range_bodies.append(body)

func _on_CloseRangeArea_body_exited(body):
	if body.is_in_group('enemies'): 
		close_range_bodies.erase(body)

func _on_ShootCD_timeout():
	can_shoot = true

func _on_HurtRedTimer_timeout():
	for sprite in $SpriteHolder.get_children():
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_AnimationPlayer_animation_finished(anim_name):
	if 'hurt' in anim_name.to_lower():
		play_animation(states.current_state.animation_name + direction_string)
