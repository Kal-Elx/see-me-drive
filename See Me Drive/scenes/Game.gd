extends Node

export var spawn_distance = 400

const x_lanes = [132, 200, 278, 350]

var last_spawn_y
var rng = RandomNumberGenerator.new()
var vehicles = []
var screen_height = ProjectSettings.get_setting("display/window/size/height")

onready var player = find_node("Player")
onready var car_scene = load("res://scenes/Car.tscn")
	
	
func _ready():
	rng.randomize()
	last_spawn_y = player.position.y
	
	
func _process(delta):
	_spawn()
	_cleanup()
	
	
# Spawns new vehicles.
func _spawn():
	if last_spawn_y - player.position.y > spawn_distance:
		last_spawn_y = player.position.y
		vehicles.append(_spawn_car(rng.randi_range(1, 4)))


# Removes passed vehicles.
func _cleanup():
	for vehicle in vehicles:
		if vehicle.position.y > player.position.y + screen_height:
			remove_child(vehicle)
			vehicles.erase(vehicle)
	
func _spawn_car(lane):
	var car = car_scene.instance()
	car.position = Vector2(x_lanes[lane-1], player.position.y - screen_height)
	car.linear_velocity *= rng.randf_range(0.85, 1.15)
	add_child(car)
	return car
