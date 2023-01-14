extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const MAX_FALL_SPEED = 500
const MAX_SPEED = 150
const JUMP_FORCE = 300
const ACCEL = 40
const FRICTION = 0.8

var motion = Vector2()

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	
	motion.y += GRAVITY
	if motion.y > MAX_FALL_SPEED:
		motion.y = MAX_FALL_SPEED
		
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	
	if Input.is_action_pressed("right_kb"):
		motion.x += ACCEL
	elif Input.is_action_pressed("left_kb"):
		motion.x -= ACCEL
	else:
		motion.x = lerp(motion.x, 0, FRICTION)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump_kb"):
			motion.y = -JUMP_FORCE
		
	motion = move_and_slide(motion, UP)
	
func set_node_indices(direction):
	pass

