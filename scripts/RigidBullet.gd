extends RigidBody2D

var direction = 1
var damage = 2
var speed = 420
var exploded = false
onready var explody_floor_frames = preload("res://resources/floor_explody.tres") 
onready var explody_air_frames = preload("res://resources/air_explody.tres") 

func _ready():
	var x = speed * direction
	linear_velocity = Vector2(x, -400)
	$AnimatedSprite.play()

func _on_Area2D_body_entered(body):
	if exploded:
		return
	if body.is_in_group('players') and body.has_method('dmg') and body.get("is_dead") == false:
		body.dmg(damage)
		show_and_play_explody()
	elif body.is_in_group("shields"):
		# TODO if reflective, bounce bullet back
		show_and_play_explody()
	elif not body.has_method("dmg"): # aka if body is a wall
		if $RayCast2D.is_colliding():
			$Explody.frames = explody_floor_frames
		show_and_play_explody()

func show_and_play_explody():
	sleeping = true
	exploded = true
	$AnimatedSprite.visible = false
	$Explody.visible = true
	$Explody.play()

func _on_Explody_animation_finished():
	queue_free()
