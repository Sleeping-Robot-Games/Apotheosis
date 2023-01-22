extends Control

var using_kb = false

var lessons_kb = [
	'Use A and D to move',
	'Left click mouse to shoot',
	'Space to jump',
	'Use 1-4 to use abilites',
	'Hold F to open upgrade menu',
]
var lessons_controller = [
	'Use analog stick to move',
	'X to shoot',
	'A to jump',
	'Use triggers to use abilities',
	'Hold Y to open upgrade menu',
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
	if lesson_index == 4:
		$Label.hide()
		$Timer.stop()
		return
	lesson_index += 1
	$Label.text = lessons[lesson_index]
