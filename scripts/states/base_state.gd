class_name BaseState
extends Node

export (String) var animation_name

# Pass in a reference to the actor's kinematic body so that it can be used by the state
var actor

func enter() -> void:
	if actor.direction == 1:
		actor.direction_string = 'Right'
	elif actor.direction == -1:
		actor.direction_string = 'Left'
	## TODO: FLIP SPRITE FOR ENEMIES
	actor.play_animation(animation_name + actor.direction_string)

func exit() -> void:
	pass

func input(_event: InputEvent) -> BaseState:
	return null

func process(_delta: float) -> BaseState:
	return null

func physics_process(_delta: float) -> BaseState:
	return null
