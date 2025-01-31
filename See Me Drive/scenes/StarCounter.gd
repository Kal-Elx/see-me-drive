extends Control

var count = 0

onready var star = get_child(0)
onready var label = get_child(1)


func _ready():
	label.text = str(count)
	

func set_color(color):
	star.modulate = color
	
	
func set_count(x):
	count = x
	label.text = str(count) if count < 1000 else "%.1fk" % (count / 1000.0)


func increment():
	set_count(count + 1)
