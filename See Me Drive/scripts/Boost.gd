extends Area2D

export var max_rotation = PI/8
export var rotation_speed = PI/2

var rotation_dir = 1


func _process(delta):
	if rotation > max_rotation:
		rotation_dir = -1
	elif rotation < -max_rotation:
		rotation_dir = 1
	rotate((rotation_speed - 2 * abs(rotation)) * delta * rotation_dir)
