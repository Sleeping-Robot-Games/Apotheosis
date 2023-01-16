extends Node2D


func _ready():
	$Tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.2, 3, 1)
	$Tween.start()

func _on_Tween_tween_all_completed():
	queue_free()

func set_sprites(holder):
	var sprite_dict = {}
	for sprite in holder.get_children():
		sprite_dict[sprite.name] = {'texture': sprite.texture, 'frame': sprite.frame}
	
	for sprite in $SpriteHolder.get_children():
		sprite.texture = sprite_dict[sprite.name].texture
		sprite.frame = sprite_dict[sprite.name].frame
