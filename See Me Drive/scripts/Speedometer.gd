extends Label

onready var _player = get_node("../../Player")

func _process(delta):
	text = _player.read_speedometer()
