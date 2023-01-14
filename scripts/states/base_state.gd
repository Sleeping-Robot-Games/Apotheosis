class_name BaseState
extends Node

# This enum is used so that each child state can reference each other for its return value
enum State {
	Null,
	Idle,
	Run,
	Fall,
	Jump
}

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

# Enums are internally stored as ints, so that is the expected return type
func input(event: InputEvent) -> int:
	return State.Null

func process(delta: float) -> int:
	return State.Null

func physics_process(delta: float) -> int:
	return State.Null
