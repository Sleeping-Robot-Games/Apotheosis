extends RigidBody2D

var direction = 1
var damage = 2
var speed = 420
var exploded = false
onready var level = get_parent()

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
	elif not body.has_method("dmg"): # aka if body is a wall
		show_and_play_explody()

func show_and_play_explody():
	sleeping = true
	exploded = true
	if $RayCast2D.is_colliding():
		$ExplodyFloor.visible = true
		$ExplodyFloor.play()
	else:
		$ExplodyAir.visible = true
		$ExplodyAir.play()
	
	$AnimatedSprite.visible = false
	g.play_sfx(level, "chickpea_mortar_explosion")

func _on_Explody_animation_finished():
	queue_free()
