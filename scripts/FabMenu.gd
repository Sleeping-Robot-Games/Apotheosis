extends Control

onready var player = get_parent()
onready var using_kb = g.player_input_devices[player.player_key] == "keyboard"
onready var button_mappings = {
	"Ability1": "1.png" if using_kb else "lb.png",
	"Ability2": "2.png" if using_kb else "lt.png",
	"Ability3": "3.png" if using_kb else "rb.png",
	"Ability4": "4.png" if using_kb else "rt.png"
}
var current_selection = null

var fab_menu_options = {
	"Ability1": [
		{"Cost": 100, "Rank": 0, "Title": "Flamethrower", "Desc": "DPS: 3\nCD: 10"},
		{"Cost": 100, "Rank": 1, "Title": "Flamethrower +1", "Desc": "DPS: 5\nCD: 10"},
		{"Cost": 100, "Rank": 2, "Title": "Flamethrower +2", "Desc": "DPS: 7\nCD: 10"},
		{"Cost": 100, "Rank": 3, "Title": "Flamethrower +3", "Desc": "DPS: 8\nCD: 10"},
		{"Cost": 100, "Rank": 4, "Title": "Flamethrower +4", "Desc": "DPS: 10\nCD: 10"}
	],
	"Ability2": [
		{"Cost": 200, "Rank": 0, "Title": "Multishot", "Desc": "DPS: 3\nCD: 10"},
		{"Cost": 200, "Rank": 1, "Title": "Multishot +1", "Desc": "DPS: 5\nCD: 10"},
		{"Cost": 200, "Rank": 2, "Title": "Multishot +2", "Desc": "DPS: 7\nCD: 10"},
		{"Cost": 200, "Rank": 3, "Title": "Multishot +3", "Desc": "DPS: 8\nCD: 10"},
		{"Cost": 200, "Rank": 4, "Title": "Multishot +4", "Desc": "DPS: 10\nCD: 10"}
	],
	"Ability3": [
		{"Cost": 250, "Rank": 0, "Title": "Sniper", "Desc": "DPS: 3\nCD: 10"},
		{"Cost": 250, "Rank": 1, "Title": "Sniper +1", "Desc": "DPS: 5\nCD: 10"},
		{"Cost": 250, "Rank": 2, "Title": "Sniper +2", "Desc": "DPS: 7\nCD: 10"},
		{"Cost": 250, "Rank": 3, "Title": "Sniper +3", "Desc": "DPS: 8\nCD: 10"},
		{"Cost": 250, "Rank": 4, "Title": "Sniper +4", "Desc": "DPS: 10\nCD: 10"}
	],
	"Ability4": [
		{"Cost": 150, "Rank": 0, "Title": "Shield", "Desc": "DPS: 3\nCD: 10"},
		{"Cost": 150, "Rank": 1, "Title": "Shield +1", "Desc": "DPS: 5\nCD: 10"},
		{"Cost": 150, "Rank": 2, "Title": "Shield +2", "Desc": "DPS: 7\nCD: 10"},
		{"Cost": 150, "Rank": 3, "Title": "Shield +3", "Desc": "DPS: 8\nCD: 10"},
		{"Cost": 150, "Rank": 4, "Title": "Shield +4", "Desc": "DPS: 10\nCD: 10"}
	],
	"Ability5": [
		{"Cost": 120, "Rank": 0, "Title": "RNG Buff", "Desc": "Passive Buff!"}
	]
}
var green = Color(0.04, 0.52, 0.11, 1.0)
var red = Color(0.52, 0.04, 0.04, 1.0)

func _ready():
	refresh()

func show_menu():
	# TODO: if any fab reminders showing hide them
	refresh()
	visible = true

func hide_menu():
	visible = false

func deselect_all():
	for i in range(1, 6):
		var ability = "Ability" + str(i)
		get_node(ability+"/Selection").visible = false
		get_node(ability).modulate.a = 0.25
	$SubMenu.visible = false
	$SubMenuBG.visible = false

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
				get_node(ability+"/Rank").texture = load("res://assets/ui/rank" + str(rank))
			get_node(ability+"/Rank").visible = rank > 0
		else:
			# selector
			var selector = load("res://assets/ui/selector_yellow.png")
			get_node(ability+"/Selection").texture = selector

func select_current():
	if fab_menu_options.has(current_selection):
		get_node(current_selection+"/Selection").visible = true
		get_node(current_selection).modulate.a = 1.0
		
		# don't render submenu if ability is maxed out
		if fab_menu_options[current_selection].size() == 0:
			return
		
		$SubMenu.visible = true
		$SubMenuBG.visible = true
		if current_selection == "Ability5":
			$SubMenu/Button.visible = false
			$SubMenu/Passive.visible = true
		else:
			$SubMenu/Button.texture = load("res://assets/ui/keys/" + button_mappings[current_selection])
			$SubMenu/Button.visible = true
			$SubMenu/Passive.visible = false

func refresh():
	deselect_all()
	update_options()
	select_current()

func _on_Ability1_mouse_entered():
	if using_kb:
		current_selection = "Ability1"
		refresh()

func _on_Ability2_mouse_entered():
	if using_kb:
		current_selection = "Ability2"
		refresh()

func _on_Ability3_mouse_entered():
	if using_kb:
		current_selection = "Ability3"
		refresh()

func _on_Ability4_mouse_entered():
	if using_kb:
		current_selection = "Ability4"
		refresh()

func _on_Ability5_mouse_entered():
	if using_kb:
		current_selection = "Ability5"
		refresh()

func _on_FabMenu_mouse_exited():
	# note: if mouse is moving too fast this might not fire
	if using_kb:
		current_selection = null
		refresh()
