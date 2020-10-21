extends CanvasLayer

onready var _speedometer = get_node("/root/Game/Speedometer")
onready var star_scene = load("res://scenes/StarCounter.tscn")
onready var green_star = star_scene.instance()
onready var yellow_star = star_scene.instance()
onready var blue_star = star_scene.instance()
onready var pink_star = star_scene.instance()
onready var stars = [pink_star, blue_star, yellow_star, green_star]


func _ready():
	add_child(green_star)
	add_child(yellow_star)
	add_child(blue_star)
	add_child(pink_star)
	green_star.set_color(_speedometer.green)
	yellow_star.set_color(_speedometer.yellow)
	blue_star.set_color(_speedometer.blue)
	pink_star.set_color(_speedometer.pink)
	green_star.set_count(_load('green'))
	yellow_star.set_count(_load('yellow'))
	blue_star.set_count(_load('blue'))
	pink_star.set_count(_load('pink'))
	_update()


func _update():
	var y = 0
	for star in stars:
		if star.count > 0:
			star.margin_top = y
			y += 35
			star.show()
		else:
			star.hide()


func new_star(star):
	match star.color:
		_speedometer.green:
			green_star.increment()
			_save(green_star, 'green')
		_speedometer.yellow:
			yellow_star.increment()
			_save(yellow_star, 'yellow')
		_speedometer.blue:
			blue_star.increment()
			_save(blue_star, 'blue')
		_speedometer.pink:
			pink_star.increment()
			_save(pink_star, 'pink')
	_update()
	
	
func _save(star, color):
	var star_count = File.new()
	var file_name = "user://{color}_count.save".format({'color' : color})
	star_count.open(file_name, File.WRITE)
	star_count.store_64(star.count)
	star_count.close()
	

func _load(color):
	var star_count = File.new()
	var file_name = "user://{color}_count.save".format({'color' : color})	
	if not star_count.file_exists(file_name):
		return 0
	star_count.open(file_name, File.READ)
	var count = star_count.get_64()
	star_count.close()
	return count
