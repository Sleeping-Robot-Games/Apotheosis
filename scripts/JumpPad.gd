extends Node2D

export var jump_force_multiplier: float = 2.0
export var disabled = false

func _ready():
	if not disabled:
		$AnimatedSprite.playing = true

func _on_Area2D_body_entered(body):
	if body.is_in_group("players") and not body.is_dead:
		if disabled:
			$Label.visible = true
		else:
			body.jump_force_multiplier = jump_force_multiplier
			body.jump_padding = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("players") and not body.is_dead:
		if disabled:
			$Label.visible = false
		else:
			body.jump_padding = false
