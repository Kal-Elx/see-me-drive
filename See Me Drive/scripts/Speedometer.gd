extends CanvasLayer

onready var _speedometer200 = get_child(0)
onready var _speedometer400 = get_child(1)
onready var _speedometer600 = get_child(2)
onready var _speedometer800 = get_child(3)
onready var _speedometer1000 = get_child(4)
onready var _player = get_owner().find_node("Player")


func _ready():
	pass
	

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
