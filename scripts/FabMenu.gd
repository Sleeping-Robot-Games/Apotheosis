extends Control

onready var player = get_parent()
onready var using_kb = g.player_input_devices[player.player_key] == "keyboard"
onready var button_mappings = {
	"Ability1": "q.png" if using_kb else "lb.png",
	"Ability2": "w.png" if using_kb else "lt.png",
	"Ability3": "e.png" if using_kb else "rb.png",
	"Ability4": "r.png" if using_kb else "rt.png"
}
var current_selection = "Ability1"


# TODO: include push force for energy pulse, replace CD on all abilities with range?
var fab_menu_options = {
	"Ability1": [
		{"Cost": 100, "Rank": 0, "Title": "Flamethrower", "Desc": "DMG: 2\nCD: 10"},
		{"Cost": 200, "Rank": 1, "Title": "Flamethrower +1", "Desc": "DMG: 4\nCD: 10"},
		{"Cost": 300, "Rank": 2, "Title": "Flamethrower +2", "Desc": "DMG: 6\nCD: 10"},
		{"Cost": 400, "Rank": 3, "Title": "Flamethrower +3", "Desc": "DMG: 8\nCD: 10"},
		{"Cost": 500, "Rank": 4, "Title": "Flamethrower +4", "Desc": "DMG: 10\nCD: 10"}
	],
	"Ability2": [
		{"Cost": 200, "Rank": 0, "Title": "Multishot", "Desc": "DMG: 3\nCD: 10"},
		{"Cost": 300, "Rank": 1, "Title": "Multishot +1", "Desc": "DMG: 4\nCD: 10"},
		{"Cost": 400, "Rank": 2, "Title": "Multishot +2", "Desc": "DMG: 5\nCD: 10"},
		{"Cost": 500, "Rank": 3, "Title": "Multishot +3", "Desc": "DMG: 6\nCD: 10"},
		{"Cost": 600, "Rank": 4, "Title": "Multishot +4", "Desc": "DMG: 7\nCD: 10"}
	],
	"Ability3": [
		{"Cost": 300, "Rank": 0, "Title": "Sniper", "Desc": "DMG: 4\nCD: 10"},
		{"Cost": 400, "Rank": 1, "Title": "Sniper +1", "Desc": "DMG: 5\nCD: 10"},
		{"Cost": 500, "Rank": 2, "Title": "Sniper +2", "Desc": "DMG: 6\nCD: 10"},
		{"Cost": 600, "Rank": 3, "Title": "Sniper +3", "Desc": "DMG: 7\nCD: 10"},
		{"Cost": 900, "Rank": 4, "Title": "Sniper +4", "Desc": "DMG: 10\nCD: 10"}
	],
	"Ability4": [
		{"Cost": 150, "Rank": 0, "Title": "Shockwave", "Desc": "DMG: 1\nPush Force: 1"},
		{"Cost": 250, "Rank": 1, "Title": "Shockwave +1", "Desc": "DMG: 2\nPush Force: 1\n>>Absorb Bullets"},
		{"Cost": 350, "Rank": 2, "Title": "Shockwave +2", "Desc": "DMG: 3\nPush Force: 1\n>>Reflect Bullets"},
		{"Cost": 450, "Rank": 3, "Title": "Shockwave +3", "Desc": "DMG: 4\nPush Force: 2\n>>Reflect Bullets"},
		{"Cost": 550, "Rank": 4, "Title": "Shockwave +4", "Desc": "DMG: 5\nPush Force: 3\n>>Reflect Bullets"}
	],
	"Ability5": [
		{"Cost": 120, "Rank": 0, "Title": "RNG", "Desc": "Passive Buff!\nRoll the dice"}
	]
}

var fab_menu_maxed_options = {
	"Ability1": {"Cost": 500, "Rank": 4, "Title": "Flamethrower +4", "Desc": "DMG: 10\nCD: 10"},
	"Ability2": {"Cost": 600, "Rank": 4, "Title": "Multishot +4", "Desc": "DMG: 7\nCD: 10"},
	"Ability3": {"Cost": 900, "Rank": 4, "Title": "Sniper +4", "Desc": "DMG: 10\nCD: 10"},
	"Ability4": {"Cost": 550, "Rank": 4, "Title": "Shockwave +4", "Desc": "DMG: 5\nPush Force: 3\n>>Reflect Bullets"},
}

var green = Color(0.04, 0.52, 0.11, 1.0)
var red = Color(0.52, 0.04, 0.04, 1.0)
var yellow = Color(0.88, 0.77, 0.23, 1.0)

func _ready():
	refresh()

func _input(event):
	if visible == false:
		return
	elif using_kb and event.is_action_pressed("ui_up"):
		focus_up()
	elif using_kb and event.is_action_pressed("ui_down"):
		focus_down()
	elif using_kb and event.is_action_pressed("ui_kb_accept"):
		attempt_purchase()
	elif not using_kb and event.is_action_pressed("ui_up_" + str(player.controller_id)):
		focus_up()
	elif not using_kb and event.is_action_pressed("ui_down_" + str(player.controller_id)):
		focus_down()
	elif not using_kb and event.is_action_pressed("ui_pad_accept") \
		and player.controller_id == str(event.device):
			attempt_purchase()

func open_menu():
	# TODO: if any fab reminders showing hide them
	current_selection = "Ability1"
	player.fab_menu_open = true
	refresh()
	visible = true

func close_menu():
	# close via a short timer to prevent player from triggering a jump when purchasing
	player.get_node("CloseFabTimer").start()
	visible = false

func _on_CloseFabTimer_timeout():
	player.fab_menu_open = false

func focus_up():
	var ability_num = int(current_selection.substr(7)) - 1
	if ability_num < 1:
		ability_num = 5
	current_selection = "Ability"+str(ability_num)
	refresh()

func focus_down():
	var ability_num = int(current_selection.substr(7)) + 1
	if ability_num > 5:
		ability_num = 1
	current_selection = "Ability"+str(ability_num)
	refresh()

func deselect_all():
	for i in range(1, 6):
		var ability = "Ability" + str(i)
		get_node(ability+"/Selection").visible = false
		get_node(ability).modulate.a = 0.25
	$SubMenu.visible = false
	$SubMenuBG.visible = false

func update_purchase_btn(playing = true):
	if player.controller_id == "kb":
		$PurchaseLabel/ControllerButton.visible = false
		$PurchaseLabel/KeyboardButton.visible = true
		$PurchaseLabel/KeyboardButton.frame = 0
		$PurchaseLabel/KeyboardButton.playing = playing
	else:
		$PurchaseLabel/KeyboardButton.visible = false
		$PurchaseLabel/ControllerButton.visible = true
		$PurchaseLabel/ControllerButton.frame = 0
		$PurchaseLabel/ControllerButton.playing = playing

func update_options():
	for i in range(1,6):
		var ability = "Ability" + str(i)
		if fab_menu_options[ability].size() > 0:
			# cost
			var cost = fab_menu_options[ability][0].Cost
			var color = green if cost <= player.scrap else red
			get_node(ability+"/Cost").text = str(cost)
			get_node(ability+"/Cost").set("custom_colors/font_color", color)
			# icon
			var ability_num = ability.substr(7)
			if color == red:
				var cd_icon = load("res://assets/ui/abilitycd_00" + ability_num + ".png")
				get_node(ability+"/Icon").texture = cd_icon
			else:
				var icon = load("res://assets/ui/ability_00" + ability_num + ".png")
				get_node(ability+"/Icon").texture = icon
			# selector
			var selector_color = "red" if color == red else "green"
			var selector = load("res://assets/ui/selector_" + selector_color + ".png")
			get_node(ability+"/Selection").texture = selector
			# cursor
			if using_kb:
				get_node(ability).mouse_filter = MOUSE_FILTER_STOP
				var cursor = CURSOR_FORBIDDEN if color == red else CURSOR_POINTING_HAND
				get_node(ability).mouse_default_cursor_shape = cursor
			else:
				get_node(ability).mouse_filter = MOUSE_FILTER_IGNORE
			# rank
			var rank = fab_menu_options[ability][0].Rank
			if rank > 0:
				get_node(ability+"/Rank").texture = load("res://assets/ui/rank" + str(rank) + ".png")
			get_node(ability+"/Rank").visible = rank > 0
		else:
			# cost
			get_node(ability+"/Cost").text = "MAX"
			get_node(ability+"/Cost").set("custom_colors/font_color", yellow)
			# icon
			var ability_num = ability.substr(7)
			var cd_icon = load("res://assets/ui/abilitycd_00" + ability_num + ".png")
			get_node(ability+"/Icon").texture = cd_icon
			# selector
			var selector = load("res://assets/ui/selector_yellow.png")
			get_node(ability+"/Selection").texture = selector
			

func select_current():
	if fab_menu_options.has(current_selection):
		get_node(current_selection+"/Selection").visible = true
		get_node(current_selection).modulate.a = 1.0
		
		var option
		var is_maxed = false
		if fab_menu_options[current_selection].size() == 0:
			is_maxed = true
			option = fab_menu_maxed_options[current_selection]
		else:
			option = fab_menu_options[current_selection][0]
		
		if is_maxed:
			$PurchaseLabel.modulate.a = 0.25
			$SubMenu.modulate.a = 0.75
			$SubMenuBG.modulate.a = 0.75
			update_purchase_btn(false)
		else:
			$SubMenu.modulate.a = 1.0
			$SubMenuBG.modulate.a = 1.0
			var cost = option.Cost
			if cost > player.scrap:
				$PurchaseLabel.modulate.a = 0.25
				update_purchase_btn(false)
			else:
				$PurchaseLabel.modulate.a = 1.0
				update_purchase_btn(true)
		
		$SubMenu/Title.text = option.Title
		$SubMenu/Desc.text = option.Desc
		$SubMenu.visible = true
		$SubMenuBG.visible = true
		if current_selection == "Ability5":
			$SubMenu/Button.visible = false
			$SubMenu/Passive.visible = true
		else:
			$SubMenu/Button.texture = load("res://assets/ui/keys/" + button_mappings[current_selection])
			$SubMenu/Button.visible = true
			$SubMenu/Passive.visible = false

func attempt_purchase():
	if fab_menu_options.has(current_selection) \
		and fab_menu_options[current_selection].size() > 0:
			var cost = fab_menu_options[current_selection][0].Cost
			if cost > player.scrap:
				return
			# purchase upgrade
			player.spend_scrap(cost)
			if current_selection == "Ability5":
				# TODO random passive buff
				pass
			else:
				var title = fab_menu_options[current_selection][0].Title
				var rank = fab_menu_options[current_selection][0].Rank
				player.show_debug_label(title)
				g.ability_ranks[player.player_key][current_selection] = rank
				g.player_ui[player.player_key].set_ability_rank(current_selection, rank)
				if rank == 0:
					update_gun_sprite(current_selection)
				fab_menu_options[current_selection].remove(0)
	close_menu()

func update_gun_sprite(ability):
	if ability == "Ability1":
		player.get_node("SpriteHolder/GunSpriteHolder/Tank").texture = load("res://assets/character/sprites/Gun/tank_001.png")
	elif ability == "Ability2":
		player.get_node("SpriteHolder/GunSpriteHolder/Scope").texture = load("res://assets/character/sprites/Gun/scope_001.png")
	elif ability == "Ability3":
		player.get_node("SpriteHolder/GunSpriteHolder/Barrel").texture = load("res://assets/character/sprites/Gun/barrel_001.png")
	elif ability == "Ability4":
		player.get_node("SpriteHolder/GunSpriteHolder/Stock").texture = load("res://assets/character/sprites/Gun/stock_001.png")

func refresh():
	deselect_all()
	update_options()
	select_current()
