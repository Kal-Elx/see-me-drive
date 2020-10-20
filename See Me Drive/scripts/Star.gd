extends Area2D

onready var _outline = get_child(0).material
onready var _player = get_node("/root/Game/Player")
onready var _speedometer = get_node("/root/Game/Speedometer")

var max_outline = 25
var min_outline = 10
var curr_outline = min_outline
var outline_speed = 15
var outline_dir = 1

func _ready():
	modulate = _speedometer.get_color(_player.get_speed())
	
func _process(delta):
	rotate(PI / 2 *delta)
	
	curr_outline += delta * outline_speed * outline_dir
	_outline.set_shader_param("outline_width", curr_outline)
	if curr_outline > max_outline or curr_outline < min_outline:
		outline_dir *= -1
