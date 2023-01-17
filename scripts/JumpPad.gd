extends Node2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("players") and not body.is_dead:
		body.jump_padding = true
