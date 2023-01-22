extends KinematicBody2D

export (bool) var ui_disabled = false
export (float) var gravity = 20.0
export (float) var friction = 0.8
export (int) var bullet_speed = 15
export (int) var hp = 10
export (float) var dash_cd = 0.5

var random = RandomNumberGenerator.new()

var max_hp = 0 # updated in ready
var velocity = Vector2()
var direction = 1
var direction_string = "Right"
var dmg_color = Color(1.0, 1.0, 1.0, 1.0)
var moving = false
var can_dash = true
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
var repair_target = null

var mods = {
	"Damage": 1,
	"Piercing": 0,
	"Push": 0,
	"Jumps": 1,
	"Dashes": 1,
	"Healing": 0,
	"Bullets": 1,
	"Dodge": 0,
	"Crit": 0,
	"Speed": 0,
	"HP": 0,
}
var jump_count = 0

var component_stage = 0

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
	if ui_disabled == false:
		$DevTimer.start()

# TODO: remove
func _on_DevTimer_timeout():
	#return
	get_scrap(3000)

func _input(event):
	if is_dead:
		return
	if repair_target != null and event.is_action_pressed("interact_"+ str(controller_id)):
		if scrap >= 500:
			spend_scrap(500)
			repair_target.repair()
			repair_target = null
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

func repair():
	is_dead = false
	hp = max_hp
	ui_disabled = false
	$RezArea/Label.visible = false
	$AnimationPlayer.play("idleRight")

func increment_max_hp():
	if is_dead:
		return
	max_hp += 1
	hp += 1
	g.player_ui[player_key].set_max_health(max_hp)
	g.player_ui[player_key].set_health(hp)

func dmg(num):
	if not is_dead and states.current_state.name != 'dash':
		var dodge_chance = mods.Dodge * 5
		var dodge_roll = random.randi_range(1, 100)
		random.randomize()
		if dodge_chance >= dodge_roll:
			$FloatTextSpawner.float_text("DODGED", g.yellow)
			return
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
			if fab_menu_open:
				$FabMenu.close_menu()
		else:
			g.play_sfx(level, "player_hit")
			if states.current_state.name == 'run':
				$AnimationPlayer.play('runHurt'+direction_string) 
			else:
				$AnimationPlayer.play('hurt'+direction_string) 

func shoot():
	if states.current_state.name == 'dash':
		return
	can_shoot = false
	$ShootCD.start()
	g.play_sfx(level, "player_shoot", -10)
	var y_offset = 0
	for i in range(mods.Bullets):
		var bullet = bullet_scene.instance()
		bullet.shot_by = 'player'
		bullet.global_position = Vector2(global_position.x + 20 * direction, global_position.y + y_offset) 
		bullet.speed = bullet_speed * direction
		random.randomize()
		var dmg = mods.Damage
		var crit_chance = mods.Crit * 5
		var crit_roll = random.randi_range(1, 100)
		if crit_chance >= crit_roll:
			$FloatTextSpawner.float_text("CRIT", g.red)
			dmg *= 2
		bullet.damage = dmg
		bullet.piercing = mods.Piercing
		bullet.push = mods.Push
		level.call_deferred('add_child', bullet)
		y_offset -= 7

func barrel_shoot():
	var bullet = bullet_scene.instance()
	bullet.shot_by = 'player'
	bullet.global_position = Vector2(global_position.x + 40 * direction, global_position.y) 
	bullet.speed = bullet_speed * direction
	bullet.duration = 5
	bullet.get_node("001").visible = false
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
	var rank = g.ability_ranks[player_key]["Ability1"]
	var rank_mods = {
		0: {"Damage": 2, "Size": 1, "Duration": 4},
		1: {"Damage": 3, "Size": 1, "Duration": 5},
		2: {"Damage": 4, "Size": 1.25, "Duration": 6},
		3: {"Damage": 5, "Size": 1.5, "Duration": 7},
		4: {"Damage": 6, "Size": 2, "Duration": 8},
	}
	
	can_use_tank = false
	g.player_ui[player_key].ability_cooldown("Ability1", $TankCD.wait_time)
	$TankCD.start()
	$TankRangeArea.scale = Vector2(rank_mods[rank].Size, rank_mods[rank].Size)
	$TankRangeArea/Particles2D.emitting = true
	$TankDuration.wait_time = rank_mods[rank].Duration
	g.play_sfx(level, "flamethrower_" + str(rank_mods[rank].Duration))
	$TankDuration.start()
	$TankDoT.start()

func use_scope():
	var rank = g.ability_ranks[player_key]["Ability2"]
	var rank_mods = {
		0: {"Damage": 3, "Targets": 2,},
		1: {"Damage": 4, "Targets": 3,},
		2: {"Damage": 5, "Targets": 4,},
		3: {"Damage": 6, "Targets": 5,},
		4: {"Damage": 7, "Targets": 7,},
	}
	
	can_use_scope = false
	g.play_sfx(level, "multishot")
	
	# sort enemies by distance to player
	var sorted_enemies = []
	for enemy in scope_range_bodies:
		if enemy and not enemy.is_dead:
			sorted_enemies.append(enemy)
	sorted_enemies.sort_custom(self, "sort_by_distance")
	
	# spawn crosshairs
	var count = 0
	for enemy in sorted_enemies:
		if enemy and not enemy.is_dead and count < rank_mods[rank].Targets:
			var enemy_distance = global_position.distance_to(enemy.global_position)
			print("distance to enemy: " + str(enemy_distance))
			var crosshair_instance = crosshair_scene.instance()
			crosshair_instance.target = enemy
			crosshair_instance.damage = rank_mods[rank].Damage
			enemy.add_child(crosshair_instance)
			count += 1
	g.player_ui[player_key].ability_cooldown("Ability2", $ScopeCD.wait_time)
	$ScopeCD.start()

func sort_by_distance(a, b):
	var a_distance = global_position.distance_to(a.global_position)
	var b_distance = global_position.distance_to(b.global_position)
	return a_distance < b_distance

func use_barrel():
	can_use_barrel = false
	laser_visible = true
	laser_flickering = true
	g.play_sfx(level, "barrel_shot")
	g.player_ui[player_key].ability_cooldown("Ability3", $BarrelCD.wait_time)
	$BarrelCD.start()
	$BarrelShot.visible = true
	$BarrelFlickerTimer.start()
	flicker_laser()

func use_stock():
	can_use_stock = false
	g.play_sfx(level, "energy_pulse")
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
	# show_debug_label('scrap: ' + str(scrap))
	# TODO: when upgrades can be purchased, show temp indicator?

func get_component(stage):
	component_stage = stage

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
		var rank_mods = {
			0: {"Damage": 2, "Size": 1, "Duration": 4},
			1: {"Damage": 3, "Size": 1, "Duration": 5},
			2: {"Damage": 4, "Size": 1.25, "Duration": 6},
			3: {"Damage": 5, "Size": 1.5, "Duration": 7},
			4: {"Damage": 6, "Size": 2, "Duration": 8},
		}
		for enemy in tank_range_bodies:
			enemy.dmg(rank_mods[rank].Damage)
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

func _on_RezArea_body_entered(body):
	if body.is_in_group('players') and body.is_dead:
		var key = "kb_up.png" if body.controller_id == "kb" else "dpad_up.png"
		body.get_node('RezArea/Label/Key').texture = load("res://assets/ui/keys/" + key)
		body.get_node('RezArea/Label').visible = true
		repair_target = body

func _on_RezArea_body_exited(body):
	if is_dead and body.is_in_group('players'):
		$RezArea/Label.visible = false
		repair_target = null

func _on_HealTimer_timeout():
	if mods.Healing > 0 and is_dead == false and hp < max_hp:
		var starting_hp = hp
		hp = clamp(hp + mods.Healing, 1, max_hp)
		g.player_ui[player_key].set_health(hp)
		var healed_hp = hp - starting_hp
		if healed_hp > 0:
			# TODO: healing particle fx
			$FloatTextSpawner.float_text("+"+str(healed_hp), g.green)
