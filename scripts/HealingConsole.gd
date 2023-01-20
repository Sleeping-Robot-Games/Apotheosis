extends Node2D

export var healing_power = 5
export var scrap_cost = 500

var is_healing = false
var heal_receiver = null

func _ready():
	$Idle.play()
	$Label.visible = false
	$Cost.visible = false
	$Cost.text = "Scrap: " + str(scrap_cost)

func _input(event):
	if heal_receiver \
		and Input.is_action_just_pressed("interact_"+ heal_receiver.controller_id) \
		and heal_receiver.scrap >= scrap_cost:
			heal_receiver.spend_scrap(scrap_cost)
			is_healing = true
			heal_receiver.ui_disabled = true
			heal_receiver.global_position = global_position
			$Idle.visible = false
			$Active.visible = true
			$Active.play()

func _on_Area2D_body_entered(body):
	if body.is_in_group('players') and not heal_receiver:
		if body.scrap >= scrap_cost:
			heal_receiver = body
			var key = "kb_up.png" if heal_receiver.controller_id == "kb" else "dpad_up.png"
			$Label/Key.texture = load("res://assets/ui/keys/" + key)
			$Label.visible = true
			$Cost.visible = true
		else:
			$Cost.visible = true

func _on_Area2D_body_exited(body):
	if body.is_in_group('players') and not is_healing:
		heal_receiver = null
		$Label.visible = false
		$Cost.visible = false

func _on_Active_animation_finished():
	$Active.visible = false
	$Idle.visible = true
	if heal_receiver:
		g.player_ui[heal_receiver.player_key].set_health(max(heal_receiver.hp + healing_power, 10))
		heal_receiver.ui_disabled = false
	is_healing = false
	$Label.visible = false
	$Cost.visible = false
