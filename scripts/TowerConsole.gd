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
	if player != null and Input.is_action_just_pressed("interact_"+ player.controller_id):
			if scrap_required > 0:
				if player.scrap >= base_required:
					player.spend_scrap(base_required)
					scrap_required = max(scrap_required - base_required, 0)
					$Label.text = 'Critical Component and \n X Scrap required to \n reassemble Sat. Tower'.replace('X', str(scrap_required))
				if scrap_required <= 0:
					$Label.text = 'Critical Component required'
					if tower_console_number == g.component_stage:
						component_delivered = true
						g.tower_state = tower_console_number
						owner.play_tower_animation(tower_console_number)
						$Label.visible = false
						$InteractLabel.visible = false
						enable_jump_pad(tower_console_number)
						clear_old_enemies(tower_console_number)
			elif scrap_required == 0:
				if tower_console_number == g.component_stage:
					component_delivered = true
					g.tower_state = tower_console_number
					owner.play_tower_animation(tower_console_number)
					$Label.visible = false
					$InteractLabel.visible = false
					enable_jump_pad(tower_console_number)
					clear_old_enemies(tower_console_number)
				else:
					$Label.text = 'Critical Component required'

func any_player_has_the_component():
	for player in get_tree().get_nodes_in_group('players'):
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

func enable_jump_pad(stage):
	for jump_pad in get_tree().get_nodes_in_group('towerjump'+str(stage)):
		jump_pad.disabled = false
		jump_pad.get_node('AnimatedSprite').playing = true

func clear_old_enemies(stage):
	for enemy in get_tree().get_nodes_in_group('tower_state_'+str(stage-1)):
		enemy.queue_free()
