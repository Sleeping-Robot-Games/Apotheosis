extends Control

var player_key
var screen_positions = {
	"p1": Vector2(0,0),
	"p2": Vector2(825,0),
	"p3": Vector2(0,450),
	"p4": Vector2(825,450)
}
# null if not unlocked, false if available, true if in cooldown
var ability_cd = {
	"Ability1": null,
	"Ability2": null,
	"Ability3": null,
	"Ability4": null,
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

func set_max_health(max_hp):
	$HealthBar.max_value = max_hp

func set_scrap(scrap):
	if scrap < 0:
		scrap = 0
	$ScrapLabel.text = str(scrap)

func set_ability_rank(ability, rank):
	# unlock ability if it wasn't already
	if ability_cd[ability] == null:
		ability_cd[ability] = false
	
	var prefix = "abilitycd_" if ability_cd[ability] else "ability_"
	if ability == "Ability1":
		$Abilities/One.texture = load("res://assets/ui/" + prefix + "001.png")
		set_rank_texture(ability, "One", rank)
	elif ability == "Ability2":
		$Abilities/Two.texture = load("res://assets/ui/" + prefix + "002.png")
		set_rank_texture(ability, "Two", rank)
	elif ability == "Ability3":
		$Abilities/Three.texture = load("res://assets/ui/" + prefix + "003.png")
		set_rank_texture(ability, "Three", rank)
	elif ability == "Ability4":
		$Abilities/Four.texture = load("res://assets/ui/" + prefix + "004.png")
		set_rank_texture(ability, "Four", rank)
	if ability_cd[ability] == null:
		ability_cd[ability] = false

func set_rank_texture(ability: String, num: String, rank: int):
	var rank_node = get_node("Abilities/" + num + "/Rank")
	if rank == 0:
		rank_node.texture = null
	elif ability_cd[ability] == true:
		rank_node.texture = load("res://assets/ui/rank"+str(rank)+"cd.png")
	else:
		rank_node.texture = load("res://assets/ui/rank"+str(rank)+".png")

func ability_cooldown(ability, duration):
	if ability_cd[ability] != false:
		return
	ability_cd[ability] = true
	if ability == "Ability1":
		$Abilities/One.texture = load("res://assets/ui/abilitycd_001.png")
		$Abilities/One/CD.visible = true
		set_rank_texture(ability, "One", g.ability_ranks[player_key][ability])
		$Abilities/One/TweenOne.interpolate_property($Abilities/One/CD, "value", 0, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Abilities/One/TweenOne.start()
	elif ability == "Ability2":
		$Abilities/Two.texture = load("res://assets/ui/abilitycd_002.png")
		$Abilities/Two/CD.visible = true
		set_rank_texture(ability, "Two", g.ability_ranks[player_key][ability])
		$Abilities/Two/TweenTwo.interpolate_property($Abilities/Two/CD, "value", 0, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Abilities/Two/TweenTwo.start()
	elif ability == "Ability3":
		$Abilities/Three.texture = load("res://assets/ui/abilitycd_003.png")
		$Abilities/Three/CD.visible = true
		set_rank_texture(ability, "Three", g.ability_ranks[player_key][ability])
		$Abilities/Three/TweenThree.interpolate_property($Abilities/Three/CD, "value", 0, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Abilities/Three/TweenThree.start()
	elif ability == "Ability4":
		$Abilities/Four.texture = load("res://assets/ui/abilitycd_004.png")
		$Abilities/Four/CD.visible = true
		set_rank_texture(ability, "Four", g.ability_ranks[player_key][ability])
		$Abilities/Four/TweenFour.interpolate_property($Abilities/Four/CD, "value", 0, 100, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Abilities/Four/TweenFour.start()

func _on_TweenOne_tween_all_completed():
	ability_cd["Ability1"] = false
	$Abilities/One.texture = load("res://assets/ui/ability_001.png")
	set_rank_texture("Ability1", "One", g.ability_ranks[player_key]["Ability1"])
	$Abilities/One/CD.visible = false

func _on_TweenTwo_tween_all_completed():
	ability_cd["Ability2"] = false
	$Abilities/Two.texture = load("res://assets/ui/ability_002.png")
	set_rank_texture("Ability2", "Two", g.ability_ranks[player_key]["Ability2"])
	$Abilities/Two/CD.visible = false

func _on_TweenThree_tween_all_completed():
	ability_cd["Ability3"] = false
	$Abilities/Three.texture = load("res://assets/ui/ability_003.png")
	set_rank_texture("Ability3", "Three", g.ability_ranks[player_key]["Ability3"])
	$Abilities/Three/CD.visible = false

func _on_TweenFour_tween_all_completed():
	ability_cd["Ability4"] = false
	$Abilities/Four.texture = load("res://assets/ui/ability_004.png")
	set_rank_texture("Ability4", "Four", g.ability_ranks[player_key]["Ability4"])
	$Abilities/Four/CD.visible = false
