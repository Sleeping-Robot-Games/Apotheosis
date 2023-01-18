extends Node2D

onready var game = owner

onready var players = $Players
onready var bgm = $BGM
onready var kill_combo = $HUD/KillCombo
onready var killstreak_fx = $HUD/Killstreak

func _ready():
	pass # Replace with function body.
	
func increment_killstreak():
	#print(g.new_timestamp() + " enemy killed incrementing combo")
	g.current_killstreak += 1
	get_node("HUD/KillCombo").text = str(g.current_killstreak)
	if g.current_killstreak >= g.killstreak_threshold:
		activate_killstreak_mode()
	get_node("KillstreakTimer").stop()
	get_node("KillstreakTimer").start()
	
func activate_killstreak_mode():
	# TODO: re-enable
	return
	if bgm.stream == null or bgm.stream.resource_path.get_file() != "cyber1.mp3":
		#print(g.new_timestamp() + "KILLSTREAK MODE ACTIVATED!! x2 Damage")
		bgm.stream = load ("res://assets/bgm/cyber1.mp3")
		bgm.play()
		killstreak_fx.visible = true
		for player in players.get_children():
			player.get_node("Killstreak").visible = true

func _on_KillstreakTimer_timeout():
	g.current_killstreak = 0
	#print(g.new_timestamp() + " Killstreak timed out resetting combo")
	kill_combo.text = "0"
	if bgm.stream.resource_path.get_file() != "background.mp3":
		#print(g.new_timestamp() + "Killstreak Mode OVER returning to normal")
		bgm.stream = load ("res://assets/bgm/background.mp3")
		bgm.play()
	killstreak_fx.visible = false
	for player in players.get_children():
		player.get_node("Killstreak").visible = false

func show_offscreen(player_key):
	game.get_node("offscreen" + player_key).visible = true

func hide_offscreen(player_key):
	game.get_node("offscreen" + player_key).visible = false
