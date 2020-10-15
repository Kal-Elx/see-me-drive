extends CanvasLayer

export var sec_to_show_count_down = 0.5
export var sec_to_pause = 3

onready var player = get_parent().get_node("Player")
onready var pause_label = get_child(0)
onready var count_down = load("res://scenes/PauseCountDown.tscn").instance()

var touching = false
var time_since_touched = 0
var paused = true
var counting_down = false

	
func _process(delta):
	if touching:
		time_since_touched = 0
		if paused or counting_down:
			_resume()
	elif not touching and not paused:
		if time_since_touched > sec_to_pause:
			_pause()
		elif time_since_touched > sec_to_show_count_down and not counting_down:
			_show_pause_count_down()
		else:
			time_since_touched += delta
	
	
func _unhandled_input(event):
	if event is InputEventScreenDrag or event is InputEventScreenTouch and event.is_pressed():
		touching = true

	# If user released screen.
	if event is InputEventScreenTouch and !event.is_pressed():
		touching = false


func _resume():
	get_tree().paused = false
	pause_label.hide()
	paused = false
	_hide_pause_count_down()
	print("resume")
	

func _pause():
	get_tree().paused = true
	pause_label.show()
	paused = true
	_hide_pause_count_down()
	print("pause")
	

func _show_pause_count_down():
	add_child(count_down)
	count_down.count_to(sec_to_pause - sec_to_show_count_down)
	counting_down = true
	print("count down")
	
	
func _hide_pause_count_down():
	counting_down = false
	remove_child(count_down)
