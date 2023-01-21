extends Node2D

export var stage = 1

func _ready():
	$AnimationPlayer.play("bounce")


func _on_Area2D_body_entered(body):
	if body.is_in_group('players'):
		body.get_component(stage)
		$Sprite.visible = false
		$Label.visible = false
		$ObtainedLabel.visible = true
		$AnimationPlayer.play("move_up")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'move_up':
		queue_free()
