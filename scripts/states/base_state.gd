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
		
	if actor.is_in_group('players'):
		actor.flip_close_range()
		actor.play_animation(animation_name + actor.direction_string)
	else:
		actor.get_node('Sprite').flip_h = actor.direction == 1
		if animation_name:
			actor.play_animation(g.parse_enemy_name(actor.name) + animation_name)
			

func exit() -> void:
	pass

func input(_event: InputEvent) -> BaseState:
	return null

func process(_delta: float) -> BaseState:
	return null

func physics_process(_delta: float) -> BaseState:
	return null
