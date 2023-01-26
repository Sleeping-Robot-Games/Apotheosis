extends Node
# warning-ignore-all:return_value_discarded

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var _amplitude = 0
var _priority = 0

onready var camera = get_parent()

func _ready():
	g.connect("shake", self, "start")

func start(duration = 0.2, frequency = 15, amplitude = 16, priority = 0):
	if priority >= _priority:
		_priority = priority
		_amplitude = amplitude
		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		$Duration.start()
		$Frequency.start()
		_new_shake()

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-_amplitude, _amplitude)
	rand.y = rand_range(-_amplitude, _amplitude)
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()
	_priority = 0

func _on_Frequency_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
