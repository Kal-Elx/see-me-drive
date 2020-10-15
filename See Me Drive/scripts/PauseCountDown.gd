extends Control

onready var progress = find_node("ProgressBar")


func _process(delta):
	progress.value += delta * 100
	
	
func count_to(sec):
	progress.max_value = sec * 100
	progress.value = 0.0
