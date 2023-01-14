class_name BaseState
extends Node

export (String) var animation_name

# Pass in a reference to the player's kinematic body so that it can be used by the state
var player

func enter() -> void:
	if player.moving == 1:
		player.direction = 'Right'
	elif player.moving == -1:
		player.direction = 'Left'
	player.play_animation(animation_name + player.direction)

func exit() -> void:
	pass

func input(event: InputEvent) -> BaseState:
	return null

func process(delta: float) -> BaseState:
	return null

func physics_process(delta: float) -> BaseState:
	return null
