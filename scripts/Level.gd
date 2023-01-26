extends Node2D
# warning-ignore-all:return_value_discarded

onready var game = owner

onready var players = $Players
onready var bgm = $BGM
onready var kill_combo = $HUD/KillCombo
onready var killstreak_fx = $HUD/Killstreak
onready var focused_texture = preload("res://assets/ui/buttonhover.png")

var killstreak_active = false
var dead_players = 0
var game_over = false

func _ready():
	get_node("Tower1").hide()
	get_node("Tower2").hide()
	get_node("Tower3").hide()

func _input(event):
	if game_over \
		and g.player_input_devices["p1"] == "joy_" + str(event.device) \
		and event.is_action_pressed("ui_pad_accept"):
			restart_game()

func player_died():
	dead_players += 1
	if dead_players >= game.num_of_players:
		game_over = true
		if g.player_input_devices["p1"] != "keyboard":
			$HUD/GameOver/Button.mouse_filter = $HUD/GameOver/Button.MOUSE_FILTER_IGNORE
			$HUD/GameOver/Button.texture_normal = focused_texture
		$AnimationPlayer.play('GameOver')

func player_repaired():
	dead_players -= 1

func increment_killstreak():
	#print(g.new_timestamp() + " enemy killed incrementing combo")
	g.current_killstreak += 1
	get_node("HUD/KillCombo").text = str(g.current_killstreak)
	if g.current_killstreak >= g.killstreak_threshold:
		activate_killstreak_mode()
	get_node("KillstreakTimer").stop()
	get_node("KillstreakTimer").start()
	
func activate_killstreak_mode():
	if killstreak_active:
		return
	#print(g.new_timestamp() + "KILLSTREAK MODE ACTIVATED!! x2 Damage")
	killstreak_active = true
	$KillstreakBGM.volume_db = -40
	$KillstreakBGM.play(15)
	$FadeInTween.stop_all()
	$FadeOutTween.stop_all()
	var bgm_volume = $BGM.volume_db
	$FadeInTween.interpolate_property($KillstreakBGM, "volume_db", -40, -10, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$FadeInTween.interpolate_property($BGM, "volume_db", bgm_volume, -40, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$FadeInTween.start()
	killstreak_fx.visible = true
	for player in players.get_children():
		if player.is_dead == false:
			player.get_node("Killstreak").visible = true

func _on_KillstreakTimer_timeout():
	g.current_killstreak = 0
	#print(g.new_timestamp() + " Killstreak timed out resetting combo")
	kill_combo.text = "0"
	if killstreak_active:
		#print(g.new_timestamp() + "Killstreak Mode OVER returning to normal")
		killstreak_active = false
		$FadeInTween.stop_all()
		$FadeOutTween.stop_all()
		var killstreak_volume = $KillstreakBGM.volume_db
		var bgm_volume = $BGM.volume_db
		$BGM.seek($KillstreakBGM.get_playback_position())
		$FadeOutTween.interpolate_property($KillstreakBGM, "volume_db", killstreak_volume, -40, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$FadeOutTween.interpolate_property($BGM, "volume_db", bgm_volume, -10, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$FadeOutTween.start()
	killstreak_fx.visible = false
	for player in players.get_children():
		player.get_node("Killstreak").visible = false

func _on_FadeOutTween_tween_all_completed():
	$KillstreakBGM.stop()

func show_offscreen(player_key):
	game.get_node("offscreen" + player_key).visible = true

func hide_offscreen(player_key):
	game.get_node("offscreen" + player_key).visible = false

func _on_EnemyHeatTimer_timeout():
	## Polls total_kills to set the progress bar and update spawners
	$HUD/ProgressBar.value = g.total_kills

func play_tower_animation(num):
	get_node("Tower"+str(num)).show()
	$AnimationPlayer.play("Tower"+str(num)+"Rise")
	g.emit_signal('shake', 3, 18, 18, 0)
	g.play_sfx(self, "tower_building")
	$TutorialLabels.hide()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'Tower3Rise':
		$AnimationPlayer.play('EndGame')
		$HUD/MissionAccomplished.text += 'Total Kills ' + str(g.total_kills)
		game_over = true
		if g.player_input_devices["p1"] != "keyboard":
			$HUD/MissionAccomplished/Button.mouse_filter = $HUD/GameOver/Button.MOUSE_FILTER_IGNORE
			$HUD/MissionAccomplished/Button.texture_normal = focused_texture
		$Camera.stop_tracking = true
		for player in get_tree().get_nodes_in_group('players'):
			player.arise()

func restart_game():
	g.reset_game_env()
	get_tree().change_scene("res://scenes/Start.tscn")

func _on_MissionAccomplishedButton_pressed():
	restart_game()

func _on_GameOverButton_pressed():
	restart_game()
