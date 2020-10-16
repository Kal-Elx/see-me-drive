extends CanvasLayer

export var sec_to_show_count_down = 0.5
export var sec_to_pause = 3
export var max_pause_outline = 8.0
export var min_pause_outline = 2.0
export var outline_speed = 12

onready var player = get_owner().find_node("Player")
onready var player_sprite = player.get_child(1)
onready var count_down = load("res://scenes/PauseCountDown.tscn").instance()

var touching = false
var time_since_touched = 0
var paused = true
var counting_down = false
var curr_pause_outline = min_pause_outline
var outline_dir = 1


func _ready():
	_set_pause_highlight_color()


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
			
	if paused:
		_highlight_player(delta)
	
	
func _unhandled_input(event):
	if event is InputEventScreenDrag or event is InputEventScreenTouch and event.is_pressed():
		touching = true
		if paused:
			player.touching = true
			player.touch_pos = event.position

	# If user released screen.
	if event is InputEventScreenTouch and !event.is_pressed():
		touching = false


func _resume():
	get_tree().paused = false
	paused = false
	_hide_pause_count_down()
	_stop_highlighting_player()
	player.wake_up()
	

func _pause():
	get_tree().paused = true
	paused = true
	_hide_pause_count_down()
	_set_pause_highlight_color()
	

func _show_pause_count_down():
	add_child(count_down)
	count_down.count_to(sec_to_pause - sec_to_show_count_down)
	counting_down = true
	
	
func _hide_pause_count_down():
	counting_down = false
	remove_child(count_down)


func _highlight_player(delta):
	curr_pause_outline += delta * outline_speed * outline_dir
	player_sprite.material.set_shader_param("outline_width", curr_pause_outline)
	if curr_pause_outline > max_pause_outline or curr_pause_outline < min_pause_outline:
		outline_dir *= -1
	
	
func _stop_highlighting_player():
	player_sprite.material.set_shader_param("outline_width", 0.0)
	curr_pause_outline = min_pause_outline
	
	
func _set_pause_highlight_color():
	player_sprite.material.set_shader_param("outline_color", Color.lightsteelblue)
