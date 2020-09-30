extends Label

onready var _player = get_node("../../Player")

func _process(delta):
	text = str(_player.get_speed())
