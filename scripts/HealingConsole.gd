extends Node2D

var scrap_cost = 10

var is_healing = false
var heal_receiver = null

func _ready():
	$Idle.play()
	$Label.visible = false
	$Cost.visible = false
	$Cost.text = "Scrap: " + str(scrap_cost)

func _input(_event):
	if heal_receiver:
		var total_scrap_cost = scrap_cost * (heal_receiver.max_hp - heal_receiver.hp)
		if Input.is_action_just_pressed("interact_"+ heal_receiver.controller_id) \
			and heal_receiver.scrap >= total_scrap_cost \
			and heal_receiver.fab_menu_open == false:
				heal_receiver.spend_scrap(total_scrap_cost)
				is_healing = true
				heal_receiver.ui_disabled = true
				heal_receiver.global_position = global_position
				$Idle.visible = false
				$Active.visible = true
				$Active.play()
				g.play_sfx(self, "healing")

func _on_Area2D_body_entered(body):
	if body.is_in_group('players') and not heal_receiver:
		var total_scrap_cost = scrap_cost * (body.max_hp - body.hp)
		if body.max_hp != body.hp and body.scrap >= total_scrap_cost:
			heal_receiver = body
			var key = "e.png" if heal_receiver.controller_id == "kb" else "dpad_up.png"
			$Label/Key.texture = load("res://assets/ui/keys/" + key)
			$Label.visible = true
			$Cost.visible = true
			$Cost.text = "Scrap: " + str(total_scrap_cost)
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
		var heal_amount = heal_receiver.max_hp
		g.player_ui[heal_receiver.player_key].set_health(heal_amount)
		heal_receiver.hp = heal_amount
		heal_receiver.ui_disabled = false
	is_healing = false
	$Label.visible = false
	$Cost.visible = false
	$Active.stop()
