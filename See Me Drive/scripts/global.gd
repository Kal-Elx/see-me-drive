extends Node

onready var player = get_node("/root/Game/Player")
onready var camera = get_node("/root/Game/Player/Camera2D")
var screen_height = ProjectSettings.get_setting("display/window/size/height")


func fromYAxis(angle):
	""" Converts the given angle to be calculated from the Y-axis. """
	var res = fmod(angle + PI/2, 2*PI)
	if res > PI:
		res -= 2*PI
	return res
	
	
func get_screen_top():
	return player.position.y + camera.offset.y - screen_height/2
	

func get_screen_bottom():
	return player.position.y + camera.offset.y + screen_height/2
