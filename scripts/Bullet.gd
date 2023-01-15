extends Node2D

export var speed = 15

func _ready():
	pass


func _physics_process(delta):
	position.x += speed


func _on_Timer_timeout():
	queue_free()
