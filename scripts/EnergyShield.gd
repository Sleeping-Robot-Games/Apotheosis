extends Node2D

func _ready():
	$Tween.interpolate_property(self, "scale", Vector2(2,2), Vector2(10, 10), 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func set_color(player_key):
	var player_color = g.get_player_color(player_key)
	$Sprite.modulate = player_color

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		body.dmg(1)
		body.push_distance = 150
		body.push_force_override = 300
		body.push_direction = -1 if body.global_position < global_position else 1
		body.is_pushed = true
	elif body.victims == "players":
		body.queue_free()

func _on_Tween_tween_all_completed():
	queue_free()
