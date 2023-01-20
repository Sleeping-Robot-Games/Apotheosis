extends Node2D

var healing = false

func _ready():
	$Idle.play()

func _on_Area2D_body_entered(body):
	if body.is_in_group('players'):
		pass # Start healing animation
		# Disable player
		# Send the global position to the healing console
		# Once active animation finishes un-disable the player
