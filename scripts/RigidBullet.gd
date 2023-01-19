extends RigidBody2D

var direction = 1
var damage = 2

func _ready():
	var x = 420 * direction
	linear_velocity = Vector2(x, -400)
	$AnimatedSprite.play()


func _on_Area2D_body_entered(body):
	if body.is_in_group('players') and body.has_method('dmg') and body.get("is_dead") == false:
		body.dmg(damage)
		queue_free()
	elif body.is_in_group("shields"):
		# TODO if reflective, bounce bullet back
		queue_free()
	elif not body.has_method("dmg"): # aka if body is a wall
		queue_free()

