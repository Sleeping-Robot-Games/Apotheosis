class_name BaseState
extends Node

export (String) var animation_name

# Pass in a reference to the actor's kinematic body so that it can be used by the state
var actor

func enter() -> void:
	if actor.moving == 1:
		actor.direction = 'Right'
	elif actor.moving == -1:
		actor.direction = 'Left'
	actor.play_animation(animation_name + actor.direction)

func exit() -> void:
	pass

func input(_event: InputEvent) -> BaseState:
	return null

func process(_delta: float) -> BaseState:
	return null

func physics_process(_delta: float) -> BaseState:
	return null
