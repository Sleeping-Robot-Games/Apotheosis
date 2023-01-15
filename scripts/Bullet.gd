extends Node2D

export var speed = 15

func _ready():
	pass


func _physics_process(_delta):
	position.x += speed


func _on_Timer_timeout():
	queue_free()


func _on_Area2D_body_entered(body):
	if not 'Player' in body and body.has_method('dmg'):
		body.dmg(1)
	queue_free()
