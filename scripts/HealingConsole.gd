extends Node2D

var is_healing = false
var healing_power = 5
var heal_receiver = null

func _ready():
	$Idle.play()
	$Label.visible = false

func _input(event):
	if heal_receiver and Input.is_action_just_pressed("fab_"+ heal_receiver.controller_id):
		is_healing = true
		heal_receiver.ui_disabled = true
		heal_receiver.global_position = global_position
		$Idle.visible = false
		$Active.visible = true
		$Active.play()

func _on_Area2D_body_entered(body):
	if body.is_in_group('players') and not heal_receiver:
		heal_receiver = body
		$Label.visible = true

func _on_Area2D_body_exited(body):
	if body.is_in_group('players') and not is_healing:
		heal_receiver = null
		$Label.visible = false

func _on_Active_animation_finished():
	$Active.visible = false
	$Idle.visible = true
	if heal_receiver:
		g.player_ui[heal_receiver.player_key].set_health(max(heal_receiver.hp + healing_power, 10))
		heal_receiver.ui_disabled = false
	is_healing = false
