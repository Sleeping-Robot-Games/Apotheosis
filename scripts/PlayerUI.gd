extends Control

var player_key
var screen_positions = {
	"p1": Vector2(0,0),
	"p2": Vector2(834,0),
	"p3": Vector2(0,456),
	"p4": Vector2(834,456)
}
# null if not unlocked, false if available, true if in cooldown
var ability_cd = {
	"Tank": null,
	"Scope": null,
	"Barrel": null,
	"Stock": null,
}

var model_folder = "res://assets/character/sprites/Head/"
var palette_folder = "res://assets/character/palettes/"
var gray_palette = palette_folder + "color_000.png"

func _ready():
	# register player ui for runtime reference
	g.player_ui[player_key] = self
	
	# move to correct corner of screen
	rect_position = screen_positions[player_key]
	
	# update label text and color to match player
	var player_color = g.get_player_color(player_key)
	$Label.modulate = player_color
	$Label.text = player_key
	
	# update sprite model and color to match player
	$Sprite.texture = load(model_folder + g.player_models[player_key])
	var player_palette = palette_folder + g.player_colors[player_key]
	$Sprite.material.set_shader_param("greyscale_palette", load(gray_palette))
	$Sprite.material.set_shader_param("palette_swap", load(player_palette))
	g.make_shaders_unique($Sprite)

func set_health(hp):
	if hp < 0:
		hp = 0
	$HealthBar.value = hp
	if hp > 3:
		$Sprite.frame = 0
		$Sprite.offset = Vector2(0,0)
	elif hp == 3 or hp ==2:
		$Sprite.frame = 20
		$Sprite.offset = Vector2(-1, -2)
	elif hp == 1:
		$Sprite.frame = 56
		$Sprite.offset = Vector2(-1, -1)
	elif hp == 0:
		$Sprite.frame = 70
		$Sprite.offset = Vector2(2, 0)

func unlock_ability(gun_part):
	if gun_part == "Tank":
		$Abilities/One.texture = load("res://assets/ui/ability_001.png")
	elif gun_part == "Scope":
		$Abilities/Two.texture = load("res://assets/ui/ability_002.png")
	elif gun_part == "Barrel":
		$Abilities/Three.texture = load("res://assets/ui/ability_003.png")
	elif gun_part == "Stock":
		$Abilities/Four.texture = load("res://assets/ui/ability_004.png")
	if ability_cd[gun_part] == null:
		ability_cd[gun_part] = false

func ability_cooldown(gun_part, duration):
	print("ability_cooldown " + gun_part + " duration:" + str(duration))
	if ability_cd[gun_part] != false:
		return
	ability_cd[gun_part] = true
	if gun_part == "Tank":
		$Abilities/One.texture = load("res://assets/ui/abilitycd_001.png")
		$Abilities/One/CD.visible = true
		$Abilities/One/TweenOne.interpolate_property($Abilities/One/CD, "value", 0, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Abilities/One/TweenOne.start()
	elif gun_part == "Scope":
		$Abilities/Two.texture = load("res://assets/ui/abilitycd_002.png")
		$Abilities/Two/CD.visible = true
		$Abilities/Two/TweenTwo.interpolate_property($Abilities/Two/CD, "value", 0, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Abilities/Two/TweenTwo.start()
	elif gun_part == "Barrel":
		$Abilities/Three.texture = load("res://assets/ui/abilitycd_003.png")
		$Abilities/Three/CD.visible = true
		$Abilities/Three/TweenThree.interpolate_property($Abilities/Three/CD, "value", 0, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Abilities/Three/TweenThree.start()
	elif gun_part == "Stock":
		$Abilities/Four.texture = load("res://assets/ui/abilitycd_004.png")
		$Abilities/Four/CD.visible = true
		$Abilities/Four/TweenFour.interpolate_property($Abilities/Four/CD, "value", 0, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Abilities/Four/TweenFour.start()

func _on_TweenOne_tween_all_completed():
	ability_cd["Tank"] = false
	$Abilities/One.texture = load("res://assets/ui/ability_001.png")
	$Abilities/One/CD.visible = false

func _on_TweenTwo_tween_all_completed():
	ability_cd["Scope"] = false
	$Abilities/Two.texture = load("res://assets/ui/ability_002.png")
	$Abilities/Two/CD.visible = false

func _on_TweenThree_tween_all_completed():
	ability_cd["Barrel"] = false
	$Abilities/Three.texture = load("res://assets/ui/ability_003.png")
	$Abilities/Three/CD.visible = false

func _on_TweenFour_tween_all_completed():
	ability_cd["Stock"] = false
	$Abilities/Four.texture = load("res://assets/ui/ability_004.png")
	$Abilities/Four/CD.visible = false
