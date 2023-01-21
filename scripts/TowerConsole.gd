extends Node2D

export var tower_console_number = 1
var player = null
var scrap_required = 2000
var base_required = scrap_required / 10

func _ready():
	scrap_required *= tower_console_number
	$Label.text = str(scrap_required) + ' Scrap required to \n reassemble Sat. Tower'
	$Label.hide()
	
func _input(event):
	if player != null \
		and Input.is_action_just_pressed("interact_"+ player.controller_id) \
		and player.scrap > 0 and player.scrap >= base_required:
			player.spend_scrap(base_required) ## FOR TESTING
			## TODO: Don't let it go negative
			scrap_required -= base_required
			$Label.text = str(scrap_required) + ' Scrap required to \n reassemble Sat. Tower'
			if scrap_required == 0:
				g.tower_state = tower_console_number
				owner.get_node('Tower' + str(tower_console_number)).show()
				if tower_console_number == 1:
					enable_jump_pad()

## TODO: Test this shit with multiple players...
func _on_Area2D_body_entered(body):
	if body.is_in_group("players"):
		$Label.visible = true
		$Label.text = str(scrap_required) + ' Scrap required to \n reassemble Sat. Tower'
		player = body


func _on_Area2D_body_exited(body):
	if body.is_in_group("players"):
		$Label.visible = false
		player = null

func enable_jump_pad():
	owner.get_node('JumpPads/TowerJumpPad').disabled = false
	owner.get_node('JumpPads/TowerJumpPad/AnimatedSprite').playing = true
