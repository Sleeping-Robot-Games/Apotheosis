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
		actor.flip()
		actor.play_animation(animation_name + actor.direction_string)
	else:
		if actor.target:
			var direction = (actor.target.global_position - actor.global_position).normalized()
			direction.y += actor.gravity
			actor.direction = -1 if actor.target.global_position.x < actor.global_position.x else 1
			
		actor.get_node('Sprite').flip_h = actor.direction == 1
		if animation_name:
			## Chumba boi get special animation treatment
			if g.parse_enemy_name(actor.name) == 'chumba':
				if name == 'chase':
					actor.is_transitioning_form = true
				var chumba_anim = animation_name
				if actor.is_transitioning_form: ## Transitiion Form means rolling up or out
					chumba_anim = 'Reform' if name == 'keep_rolling' else 'RollingUp'
				actor.play_animation('chumba' + chumba_anim)
			else:
				actor.play_animation(g.parse_enemy_name(actor.name).replace('alt', '') + animation_name)
			

func exit() -> void:
	pass

func input(_event: InputEvent) -> BaseState:
	return null

func process(_delta: float) -> BaseState:
	return null

func physics_process(_delta: float) -> BaseState:
	return null
