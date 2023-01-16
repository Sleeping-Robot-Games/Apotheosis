extends RigidBody2D

var random = RandomNumberGenerator.new()

func _ready():
	random.randomize()
	var x = random.randi_range(30, 70) * ((random.randi_range(0, 1) * 2) - 1)
	var y = random.randi_range(-200, -300)
	linear_velocity = Vector2(x, y)

func _on_Area2D_body_entered(body):
	if body.is_in_group('players'):
		body.get_scrap()
		queue_free()
