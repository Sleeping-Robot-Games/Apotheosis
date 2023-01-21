extends Node2D

export var tower_console_number = 1
var player = null
var scrap_required = 2000
var base_required = scrap_required / 10
var component_delivered = false

func _ready():
	scrap_required *= tower_console_number
	$Label.text = 'Critical Component and \n X Scrap required to \n reassemble Sat. Tower'.replace('X', str(scrap_required))
	$Label.hide()
	$InteractLabel.hide()
	
func _input(event):
	if player != null \
		and Input.is_action_just_pressed("interact_"+ player.controller_id) \
		and player.scrap > 0 and player.scrap >= base_required:
			player.spend_scrap(base_required) ## FOR TESTING
			## TODO: Don't let it go negative
			scrap_required = max(scrap_required - base_required, 0)
			$Label.text = 'Critical Component and \n X Scrap required to \n reassemble Sat. Tower'.replace('X', str(scrap_required))
			if scrap_required == 0:
				print(any_player_has_the_component())
				if any_player_has_the_component():
					component_delivered = true
					g.tower_state = tower_console_number
					owner.get_node('Tower' + str(tower_console_number)).show()
					$Label.visible = false
					$InteractLabel.visible = false
					if tower_console_number == 1:
						enable_jump_pad()
				else:
					$Label.text = 'Critical Component required'

func any_player_has_the_component():
	for player in owner.get_node('Players').get_children():
		print(player.component_stage)
		if player.component_stage == tower_console_number:
			return true
		return false

## TODO: SHOW THE RIGHT MESSAGE IF THE PLAYERS DON'T HAVE THE COMPONENT
func _on_Area2D_body_entered(body):
	if body.is_in_group("players"):
		if scrap_required == 0 and component_delivered:
			return
			
		$Label.visible = true
		
		if scrap_required > 0 and not component_delivered:
			$Label.text = 'Critical Component and \n {scrap} Scrap required to \n reassemble Sat. Tower'.format({'scrap': str(scrap_required)})
		else:
			$Label.text = 'Critical Component required'
		
		var key = "kb_up.png" if body.controller_id == "kb" else "dpad_up.png"
		$InteractLabel/Key.texture = load("res://assets/ui/keys/" + key)
		$InteractLabel.visible = true
		player = body

func _on_Area2D_body_exited(body):
	if body.is_in_group("players"):
		$Label.visible = false
		$InteractLabel.visible = false
		player = null

func enable_jump_pad():
	owner.get_node('JumpPads/TowerJumpPad').disabled = false
	owner.get_node('JumpPads/TowerJumpPad/AnimatedSprite').playing = true
