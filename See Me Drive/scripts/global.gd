extends Node

func fromYAxis(angle):
	""" Converts the given angle to be calculated from the Y-axis. """
	var res = fmod(angle + PI/2, 2*PI)
	if res > PI:
		res -= 2*PI
	return res
