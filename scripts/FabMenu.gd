extends Control

onready var player = get_parent()
onready var using_kb = g.player_input_devices[player.player_key] == "keyboard"
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
		{"Cost": 100, "Rank": 0, "Title": "Multishot", "Desc": "DPS: 3\nCD: 10"},
		{"Cost": 100, "Rank": 1, "Title": "Multishot +1", "Desc": "DPS: 5\nCD: 10"},
		{"Cost": 100, "Rank": 2, "Title": "Multishot +2", "Desc": "DPS: 7\nCD: 10"},
		{"Cost": 100, "Rank": 3, "Title": "Multishot +3", "Desc": "DPS: 8\nCD: 10"},
		{"Cost": 100, "Rank": 4, "Title": "Multishot +4", "Desc": "DPS: 10\nCD: 10"}
	],
	"Ability3": [
		{"Cost": 100, "Rank": 0, "Title": "Sniper", "Desc": "DPS: 3\nCD: 10"},
		{"Cost": 100, "Rank": 1, "Title": "Sniper +1", "Desc": "DPS: 5\nCD: 10"},
		{"Cost": 100, "Rank": 2, "Title": "Sniper +2", "Desc": "DPS: 7\nCD: 10"},
		{"Cost": 100, "Rank": 3, "Title": "Sniper +3", "Desc": "DPS: 8\nCD: 10"},
		{"Cost": 100, "Rank": 4, "Title": "Sniper +4", "Desc": "DPS: 10\nCD: 10"}
	],
	"Ability4": [
		{"Cost": 100, "Rank": 0, "Title": "Shield", "Desc": "DPS: 3\nCD: 10"},
		{"Cost": 100, "Rank": 1, "Title": "Shield +1", "Desc": "DPS: 5\nCD: 10"},
		{"Cost": 100, "Rank": 2, "Title": "Shield +2", "Desc": "DPS: 7\nCD: 10"},
		{"Cost": 100, "Rank": 3, "Title": "Shield +3", "Desc": "DPS: 8\nCD: 10"},
		{"Cost": 100, "Rank": 4, "Title": "Shield +4", "Desc": "DPS: 10\nCD: 10"}
	],
	"Ability5": [
		{"Cost": 100, "Rank": 0, "Title": "RNG Buff", "Desc": "Passive Buff!"}
	]
}

func _ready():
	if using_kb:
		print("using_kb = TRUE")
		$Ability1/SubMenu/Button.texture = load("res://assets/ui/keys/tile_0323.png")
		$Ability2/SubMenu/Button.texture = load("res://assets/ui/keys/tile_0324.png")
		$Ability3/SubMenu/Button.texture = load("res://assets/ui/keys/tile_0325.png")
		$Ability4/SubMenu/Button.texture = load("res://assets/ui/keys/tile_0326.png")
	else:
		print("using_kb = FALSE")
		# TODO: prevent mouse interaction
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
		get_node(ability+"/SubMenuBG").visible = false
		get_node(ability+"/SubMenu").visible = false
		get_node(ability).modulate.a = 0.25
		#get_node(ability+"/Cost").modulate.a = 0.25
		#get_node(ability+"/Scrap").modulate.a = 0.25
		#get_node(ability+"/Icon").modulate.a = 0.25
		#get_node(ability+"/Rank").modulate.a = 0.25

func refresh():
	deselect_all()
	if fab_menu_options.has(current_selection):
		get_node(current_selection+"/Selection").visible = true
		get_node(current_selection+"/SubMenuBG").visible = true
		get_node(current_selection+"/SubMenu").visible = true
		get_node(current_selection).modulate.a = 1.0

func _on_Ability1_mouse_entered():
	print("Ability1 Mouse Entered")
	if using_kb:
		current_selection = "Ability1"
		refresh()

func _on_Ability2_mouse_entered():
	print("Ability2 Mouse Entered")
	if using_kb:
		current_selection = "Ability2"
		refresh()

func _on_Ability3_mouse_entered():
	print("Ability3 Mouse Entered")
	if using_kb:
		current_selection = "Ability3"
		refresh()

func _on_Ability4_mouse_entered():
	print("Ability4 Mouse Entered")
	if using_kb:
		current_selection = "Ability4"
		refresh()

func _on_Ability5_mouse_entered():
	print("Ability5 Mouse Entered")
	if using_kb:
		current_selection = "Ability5"
		refresh()

func _on_FabMenu_mouse_exited():
	print("Fab Menu mouse exited")
	if using_kb:
		current_selection = null
		refresh()
