extends KinematicBody2D

export (bool) var ui_disabled = false
export (float) var gravity = 20.0
export (float) var friction = 0.8
export (int) var bullet_speed = 15
export (int) var hp = 10

var velocity = Vector2()
var direction = 1
var direction_string = "Right"
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
var scrap = 200
var scope_range_bodies = []
var tank_range_bodies = []
var upgrade_cost = [10, 10, 10, 10, 2000]

var current_upgrade = 0
#var can_fabricate = false
var fab_menu_open = false
var fabricating_progress = 0
var upgrades = {
	'Tank': [],
	'Barrel': [],
	'Scope': [],
	'Stock': []
}

onready var states = $state_manager
## TODO: change how game scene is assigned when implementing levels?

onready var level = null if ui_disabled else get_node('../../../Level')
onready var bullet_scene = preload("res://scenes/Bullet.tscn")
onready var crosshair_scene = preload("res://scenes/Crosshair.tscn")
onready var energy_shield_scene = preload("res://scenes/EnergyShield.tscn")

## FOR DEBUGGING
func show_debug_label(text):
	$debug_label.text = text
	$debug_label/Timer.start()
	
func _on_debugTimer_timeout():
	$debug_label.text = ""
	
func _ready():
	states.init(self)

func _input(event):
	#if can_fabricate and event.is_action_pressed("fab_" + str(controller_id)):
	#	show_fabricate_icon(true)
	#elif can_fabricate and event.is_action_released("fab_" + str(controller_id)):
	#	show_fabricate_icon(false)
	if event.is_action_pressed("fab_" + str(controller_id)):
		fab_menu_open = !fab_menu_open
		if fab_menu_open:
			$FabMenu.show_menu()
		else:
			$FabMenu.hide_menu()
	elif can_use_tank and upgrades["Tank"].size() > 0 and Input.is_action_pressed("ability_a_" + controller_id):
		use_tank()
	elif can_use_scope and upgrades["Scope"].size() > 0 and Input.is_action_pressed("ability_b_" + controller_id):
		use_scope()
	elif can_use_barrel and upgrades["Barrel"].size() > 0 and Input.is_action_pressed("ability_c_" + controller_id):
		use_barrel()
	elif can_use_stock and upgrades["Stock"].size() > 0 and Input.is_action_pressed("ability_d_" + controller_id):
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
	
	if can_shoot and Input.is_action_pressed("shoot_" + controller_id):
		shoot()
	
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
	apply_upgrades(bullet)
	level.call_deferred('add_child', bullet)

func barrel_shoot():
	var bullet = bullet_scene.instance()
	bullet.shot_by = 'player'
	bullet.global_position = Vector2(global_position.x + 40 * direction, global_position.y) 
	bullet.speed = bullet_speed * direction
	bullet.get_node("001").visible = false
	bullet.get_node("003").visible = true
	bullet.damage = 5
	bullet.piercing = true
	level.call_deferred('add_child', bullet)

func use_scope():
	print("USING SCOPE")
	can_use_scope = false
	for enemy in scope_range_bodies:
		if enemy and not enemy.is_dead:
			var crosshair_instance = crosshair_scene.instance()
			crosshair_instance.target = enemy
			enemy.add_child(crosshair_instance)
	g.player_ui[player_key].ability_cooldown("Scope", $ScopeCD.wait_time)
	$ScopeCD.start()

func use_tank():
	print("USING TANK")
	can_use_tank = false
	g.player_ui[player_key].ability_cooldown("Tank", $TankCD.wait_time)
	$TankCD.start()
	$TankRangeArea/Particles2D.emitting = true
	$TankDuration.start()
	$TankDoT.start()

func use_barrel():
	print("USING BARREL")
	can_use_barrel = false
	laser_visible = true
	laser_flickering = true
	g.player_ui[player_key].ability_cooldown("Barrel", $BarrelCD.wait_time)
	$BarrelCD.start()
	$BarrelShot.visible = true
	$BarrelFlickerTimer.start()
	flicker_laser()

func use_stock():
	print("USING STOCK")
	can_use_stock = false
	g.player_ui[player_key].ability_cooldown("Stock", $StockCD.wait_time)
	$StockCD.start()
	var energy_shield_instance = energy_shield_scene.instance()
	energy_shield_instance.set_color(player_key)
	add_child(energy_shield_instance)

func flicker_laser():
	$BarrelFlickerTween.interpolate_property($BarrelShot/Laser, "modulate:a", 0, 1.0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$BarrelFlickerTween.start()

func apply_upgrades(bullet):
	## TODO: Check to see what to apply
#	Scope - Range
	apply_range(1)
#	Barrel - Piercing
	apply_pierce()
#	Tank - Flame
	apply_tank_range()
#	Handle - Pushback
	apply_push(1)

func apply_pierce():
	pass

func apply_range(num):
	pass
	
func apply_tank_range():
	pass

func apply_push(num):
	pass

func get_scrap():
	scrap += 10
	show_debug_label('scrap: ' + str(scrap))
	# TODO: when upgrades can be purchased, show temp indicator
	#if upgrade_cost.size() > 0 and scrap >= upgrade_cost[0]:
	#	can_fabricate = true
	#	show_fabricate_icon()

func show_fabricate_icon(pressed = false):
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
	scrap -= upgrade_cost[0]
	if current_upgrade == 0:
		show_debug_label("FLAMETHROWER INSTALLED")
		upgrades["Tank"].append("Flame")
		g.player_ui[player_key].unlock_ability("Tank")
		$SpriteHolder/GunSpriteHolder/Tank.texture = load("res://assets/character/sprites/Gun/tank_001.png")
	elif current_upgrade == 1:
		show_debug_label("SMART SCOPE INSTALLED")
		upgrades["Scope"].append("Multishot")
		g.player_ui[player_key].unlock_ability("Scope")
		$SpriteHolder/GunSpriteHolder/Scope.texture = load("res://assets/character/sprites/Gun/scope_001.png")
	elif current_upgrade == 2:
		show_debug_label("SNIPER BARREL INSTALLED")
		upgrades["Barrel"].append("Sniper")
		g.player_ui[player_key].unlock_ability("Barrel")
		$SpriteHolder/GunSpriteHolder/Barrel.texture = load("res://assets/character/sprites/Gun/barrel_001.png")
	elif current_upgrade == 3:
		show_debug_label("ENERGY SHIELD INSTALLED")
		upgrades["Stock"].append("EnergyShield")
		g.player_ui[player_key].unlock_ability("Stock")
		$SpriteHolder/GunSpriteHolder/Stock.texture = load("res://assets/character/sprites/Gun/stock_001.png")
	elif current_upgrade == 4:
		# TODO Random Passive Bonus
		pass
	
	current_upgrade += 1
	upgrade_cost.remove(0)
	#can_fabricate = false
	if upgrade_cost.size() > 0 and scrap >= upgrade_cost[0]:
		#can_fabricate = true
		show_fabricate_icon()
		
func flip():
	$TankRangeArea.rotation_degrees = 180 if direction == 1 else 0
	$BarrelShot.rotation_degrees = 180 if direction == 1 else 0
	if $TankRangeArea.rotation_degrees == 180:
		$TankRangeArea/Particles2D.process_material.set("orbit_velocity", -0.1)
	else:
		$TankRangeArea/Particles2D.process_material.set("orbit_velocity", 0.1)

func _on_FabricateTween_tween_all_completed():
	$Fabricate.visible = false
	#can_fabricate = false
	fabricating_progress = 0
	random_upgrade()

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
	show_debug_label("tank off cooldown")
	can_use_tank = true

func _on_TankDoT_timeout():
	print("TankDoT")
	# TODO: different fx for different tanks? e.g., lightning applies short stun?
	if $TankDuration.time_left > 0:
		for enemy in tank_range_bodies:
			enemy.dmg(2)
		$TankDoT.start()

func _on_TankRangeArea_body_entered(body):
	if body.is_in_group('enemies'): 
		tank_range_bodies.append(body)

func _on_TankRangeArea_body_exited(body):
	if body.is_in_group('enemies'): 
		tank_range_bodies.erase(body)

func _on_ScopeCD_timeout():
	show_debug_label("scope off cooldown")
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
	show_debug_label("barrel off cooldown")
	can_use_barrel = true

func _on_StockCD_timeout():
	show_debug_label("stock off cooldown")
	can_use_stock = true
