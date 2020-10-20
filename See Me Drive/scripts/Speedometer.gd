extends CanvasLayer

var grey = Color('96000000')
var white = Color('96ffffff')
var green = Color('9633e633')
var yellow = Color('96f5fd03')
var blue = Color('9600a5ff')
var pink = Color('96ea44f8')

onready var _speedometer200 = get_child(0)
onready var _speedometer400 = get_child(1)
onready var _speedometer600 = get_child(2)
onready var _speedometer800 = get_child(3)
onready var _speedometer1000 = get_child(4)
onready var _player = get_owner().find_node("Player")


func _ready():
	_speedometer200.set_colors(grey, white)
	_speedometer400.set_colors(Color.transparent, green)
	_speedometer600.set_colors(Color.transparent, yellow)
	_speedometer800.set_colors(Color.transparent, blue)
	_speedometer1000.set_colors(Color.transparent, pink)
	
	
func _process(delta):
	var speed = _player.get_speed()
	_set_speed(_speedometer200, 200, speed)
	_set_speed(_speedometer400, 400, speed)
	_set_speed(_speedometer600, 600, speed)
	_set_speed(_speedometer800, 800, speed)
	_set_speed(_speedometer1000, 1000, speed)


func _set_speed(speedometer, limit, speed):
	if speed > limit - 200 and speed <= limit:
		speedometer.set_progress(fmod(speed, 200.0))
	else:
		speedometer.set_progress(0)


func get_color(speed):
	var color_index = int(speed) / 200
	match color_index:
		0:
			return white
		1:
			return green
		2: 
			return yellow
		3:
			return blue
		4:
			return pink
		_:
			return white
