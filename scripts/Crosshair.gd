extends Node2D

var target

func _ready():	
	$Tween.interpolate_property(self, "scale",  Vector2(10,10), Vector2.ONE, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_all_completed():
	if target and not target.is_dead:
		target.dmg(5)
	queue_free()
