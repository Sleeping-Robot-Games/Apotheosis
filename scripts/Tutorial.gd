extends Control

var using_kb = false

var lessons_kb = [
	'Use A and D to move',
	'Left click mouse to shoot',
	'Space to jump',
	'Shift to dash',
	'1-4 keys to use abilites once \n built with scrap',
	'Press F to open fabricate menu',
]
var lessons_controller = [
	'Use analog stick to move',
	'X to shoot',
	'A to jump',
	'B to dash',
	'Triggers to use abilites once \n built with scrap',
	'Press Y to open fabricate menu',
]
var lessons = []
var lesson_index = 0

func _ready():
	using_kb = owner.controller_id == "kb"
	if using_kb:
		lessons = lessons_kb
	else:
		lessons = lessons_controller
	$Label.text = lessons[lesson_index]

func show_tutorial():
	$Timer.start()
	$Label.show()

func _on_Timer_timeout():
	if lesson_index == 5:
		$Label.hide()
		$Timer.stop()
		return
	lesson_index += 1
	$Label.text = lessons[lesson_index]
