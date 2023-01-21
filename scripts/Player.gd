extends KinematicBody2D

export (bool) var ui_disabled = false
export (float) var gravity = 20.0
export (float) var friction = 0.8
export (int) var bullet_speed = 15
export (int) var hp = 10

var max_hp = 0 # updated in ready
var velocity = Vector2()
var direction = 1
var direction_string = "Right"
var dmg_color = Color(1.0, 1.0, 1.0, 1.0)
var moving = false
var can_dash = true
var can_jump = true
var can_shoot = true
var can_use_scope = true
var can_use_tank = true
var can_use_barrel = true
var can_use_stock = true
var laser_visible = true
var laser_flickering = false
var can_slash = true
var is_dead = false
var jump_padding = false
var player_key = "p1"
var controller_id = "kb"
var prev_anim = ""
var scrap = 0
var scope_range_bodies = []
var tank_range_bodies = []
var upgrade_cost = [10, 10, 10, 10, 2000]
var current_upgrade = 0
var fab_menu_open = false
var fabricating_progress = 0
var jump_force_multiplier = 2
# TODO: other RNG mods (push, piercing, etc)
var bullet_mods = {
	"Damage": 1,
	"Piercing": 0,
	"PushForce": 0,
	"PushDistance": 0,
}

onready var states = $state_manager
onready var level = null if ui_disabled else get_node('../../../Level')
onready var bullet_scene = preload("res://scenes/Bullet.tscn")
onready var crosshair_scene = preload("res://scenes/Crosshair.tscn")
onready var energy_pulse_scene = preload("res://scenes/EnergyPulse.tscn")

## FOR DEBUGGING
func show_debug_label(text):
	$debug_label.text = text
	$debug_label/Timer.start()
	
func _on_debugTimer_timeout():
	$debug_label.text = ""
	
func _ready():
	max_hp = hp
	dmg_color = g.get_player_color(player_key, 2)
	states.init(self)

# TODO: remove
func _on_DevTimer_timeout():
	get_scrap(3000)

func _input(event):
	if fab_menu_open == false and event.is_action_pressed("fab_" + str(controller_id)):
		start_fabricator()
	elif fab_menu_open == false and event.is_action_released("fab_" + str(controller_id)):
		stop_fabricator()
	elif fab_menu_open == true and event.is_action_pressed("fab_" + str(controller_id)):
		$FabMenu.close_menu()
	
	if can_shoot and Input.is_action_pressed("shoot_" + controller_id) and not ui_disabled:
		shoot()
	elif can_use_tank and g.ability_ranks[player_key]["Ability1"] > -1 and Input.is_action_pressed("ability_a_" + controller_id):
		use_tank()
	elif can_use_scope and g.ability_ranks[player_key]["Ability2"] > -1 and Input.is_action_pressed("ability_b_" + controller_id):
		use_scope()
	elif can_use_barrel and g.ability_ranks[player_key]["Ability3"] > -1 and Input.is_action_pressed("ability_c_" + controller_id):
		use_barrel()
	elif can_use_stock and g.ability_ranks[player_key]["Ability4"] > -1 and Input.is_action_pressed("ability_d_" + controller_id):
		use_stock()

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
	
	if laser_visible:
		var barrel_offset = 32
		var max_distance = -1968
		if $BarrelShot/Raycast2D.is_colliding():
			var collision_point = $BarrelShot/Raycast2D.get_collision_point()
			var laser_distance = global_position.distance_to(collision_point)
			$BarrelShot/Laser.rect_position.x = clamp(abs(laser_distance) * -1, max_distance, barrel_offset * -1)
		else:
			$BarrelShot/Laser.rect_position.x = max_distance
		$BarrelShot/Laser.rect_size.x = abs($BarrelShot/Laser.rect_position.x) - barrel_offset

func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)

func dmg(num):
	if not is_dead:
		hp -= num
		$FloatTextSpawner.float_text(str(num), dmg_color)
		g.player_ui[player_key].set_health(hp)
		for sprite in $SpriteHolder.get_children():
			sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
		$HurtRedTimer.start()
		if hp <= 0:
			$AnimationPlayer.play('death'+direction_string) ## TODO: Temp, use state
			is_dead = true
			ui_disabled = true
			g.play_sfx(level, "player_death")
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
	bullet.global_position = Vector2(global_position.x + 40 * direction, global_position.y) 
	bullet.speed = bullet_speed * direction
	bullet.damage = bullet_mods.damage
	level.call_deferred('add_child', bullet)

func barrel_shoot():
	var bullet = bullet_scene.instance()
	bullet.shot_by = 'player'
	bullet.global_position = Vector2(global_position.x + 40 * direction, global_position.y) 
	bullet.speed = bullet_speed * direction
	bullet.get_node("001").visible = false
	bullet.get_node("003").visible = true
	var rank = g.ability_ranks[player_key]["Ability3"]	
	var rank_mods = {
		0: {"Damage": 4, "Piercing": 1,},
		1: {"Damage": 5, "Piercing": 2,},
		2: {"Damage": 6, "Piercing": 3,},
		3: {"Damage": 7, "Piercing": 4,},
		4: {"Damage": 10, "Piercing": 5,},
	}	
	bullet.damage = rank_mods[rank].Damage
	bullet.piercing = rank_mods[rank].Piercing
	level.call_deferred('add_child', bullet)

func use_tank():
	can_use_tank = false
	g.player_ui[player_key].ability_cooldown("Ability1", $TankCD.wait_time)
	$TankCD.start()
	$TankRangeArea/Particles2D.emitting = true
	$TankDuration.start()
	$TankDoT.start()

func use_scope():
	can_use_scope = false
	for enemy in scope_range_bodies:
		if enemy and not enemy.is_dead:
			var crosshair_instance = crosshair_scene.instance()
			crosshair_instance.rank = g.ability_ranks[player_key]["Ability2"]
			crosshair_instance.target = enemy
			enemy.add_child(crosshair_instance)
	g.player_ui[player_key].ability_cooldown("Ability2", $ScopeCD.wait_time)
	$ScopeCD.start()

func use_barrel():
	can_use_barrel = false
	laser_visible = true
	laser_flickering = true
	g.player_ui[player_key].ability_cooldown("Ability3", $BarrelCD.wait_time)
	$BarrelCD.start()
	$BarrelShot.visible = true
	$BarrelFlickerTimer.start()
	flicker_laser()

func use_stock():
	can_use_stock = false
	g.player_ui[player_key].ability_cooldown("Ability4", $StockCD.wait_time)
	$StockCD.start()
	var energy_pulse_instance = energy_pulse_scene.instance()
	energy_pulse_instance.set_color(player_key)
	energy_pulse_instance.rank = g.ability_ranks[player_key]["Ability4"]
	add_child(energy_pulse_instance)

func flicker_laser():
	$BarrelFlickerTween.interpolate_property($BarrelShot/Laser, "modulate:a", 0, 1.0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$BarrelFlickerTween.start()

func get_scrap(amount = 10):
	scrap += amount
	g.player_ui[player_key].set_scrap(scrap)
	$FabMenu.refresh()
	show_debug_label('scrap: ' + str(scrap))
	# TODO: when upgrades can be purchased, show temp indicator?

func spend_scrap(amount):
	scrap -= amount
	if scrap < 0:
		scrap = 0
	g.player_ui[player_key].set_scrap(scrap)

func start_fabricator():
	$FabPrep/StopTween.stop_all()
	var btn = "F" if controller_id == "kb" else "Y"
	$FabPrep/Label.text = "Starting Fabricator..."
	$FabPrep/Icon.texture = load("res://assets/" + btn + "_002.png")
	$FabPrep.visible = true
	# TODO: match time to fabricate animation?
	var current_progress = $FabPrep/Progress.value
	var duration = (100 - current_progress) * 0.01
	$FabPrep/StartTween.interpolate_property($FabPrep/Progress, "value", current_progress, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$FabPrep/StartTween.start()

func stop_fabricator():
	$FabPrep/StartTween.stop_all()
	var btn = "F" if controller_id == "kb" else "Y"
	$FabPrep/Label.text = "Stopping Fabricator..."
	$FabPrep/Icon.texture = load("res://assets/" + btn + "_001.png")
	$FabPrep.visible = true
	# TODO: match time to fabricate animation?
	var current_progress = $FabPrep/Progress.value
	var duration = current_progress * 0.01
	$FabPrep/StopTween.interpolate_property($FabPrep/Progress, "value", current_progress, 0, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$FabPrep/StopTween.start()

func flip():
	$TankRangeArea.rotation_degrees = 180 if direction == 1 else 0
	$BarrelShot.rotation_degrees = 180 if direction == 1 else 0

func _on_StartTween_tween_all_completed():
	$FabPrep.visible = false
	$FabPrep/Progress.value = 0
	$FabMenu.open_menu()

func _on_StopTween_tween_all_completed():
	$FabPrep.visible = false

func _on_ShootCD_timeout():
	can_shoot = true

func _on_HurtRedTimer_timeout():
	for sprite in $SpriteHolder.get_children():
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_AnimationPlayer_animation_finished(anim_name):
	if 'hurt' in anim_name.to_lower():
		play_animation(states.current_state.animation_name + direction_string)

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	if not ui_disabled and viewport.name == 'Viewport':
		level.show_offscreen(player_key)

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	if not ui_disabled and viewport.name == 'Viewport':
		level.hide_offscreen(player_key)

func _on_TankDuration_timeout():
	$TankRangeArea/Particles2D.emitting = false

func _on_TankCD_timeout():
	can_use_tank = true

func _on_TankDoT_timeout():
	# TODO: different fx for different tanks? e.g., lightning applies short stun?
	if $TankDuration.time_left > 0:
		var rank = g.ability_ranks[player_key]["Ability1"]
		var damage = {
			0: 2,
			1: 4,
			2: 6,
			3: 8,
			4: 10
		}
		for enemy in tank_range_bodies:
			enemy.dmg(damage[rank])
		$TankDoT.start()

func _on_TankRangeArea_body_entered(body):
	if body.is_in_group('enemies'): 
		tank_range_bodies.append(body)

func _on_TankRangeArea_body_exited(body):
	if body.is_in_group('enemies'): 
		tank_range_bodies.erase(body)

func _on_ScopeCD_timeout():
	can_use_scope = true

func _on_ScopeRangeArea_body_entered(body):
	if body.is_in_group('enemies'): 
		scope_range_bodies.append(body)

func _on_ScopeRangeArea_body_exited(body):
	if body.is_in_group('enemies'): 
		scope_range_bodies.erase(body)

func _on_BarrelFlickerTween_tween_all_completed():
	if $BarrelFlickerTimer.time_left > 0:
		flicker_laser()
	else:
		laser_flickering = false
		$BarrelLaserTimer.start()

func _on_BarrelLaserTimer_timeout():
	laser_visible = false
	$BarrelShot.visible = false
	barrel_shoot()

func _on_BarrelCD_timeout():
	can_use_barrel = true

func _on_StockCD_timeout():
	can_use_stock = true
