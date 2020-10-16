extends Node

export var spawn_distance = 400
export var blur_factor = 0.2

const x_lanes = [140, 208, 280, 358]

var last_spawn_y
var rng = RandomNumberGenerator.new()
var screen_height = ProjectSettings.get_setting("display/window/size/height")

onready var player = find_node("Player")
onready var background = find_node("Road").get_child(0).get_child(0).get_child(0).material
onready var camera = find_node("Camera2D")
onready var car_scene = load("res://scenes/Car.tscn")
onready var taxi_scene = load("res://scenes/Taxi.tscn")
onready var mini_truck_scene = load("res://scenes/MiniTruck.tscn")
onready var mini_van_scene = load("res://scenes/MiniVan.tscn")
onready var truck_scene = load("res://scenes/Truck.tscn")
onready var ambulance_scene = load("res://scenes/Ambulance.tscn")
onready var viper_scene = load("res://scenes/Viper.tscn")
	
	
func _ready():
	rng.randomize()
	last_spawn_y = player.position.y
	

func _process(delta):
	# TODO: Possible optimization, call this with a time interval.
	_spawn()
	_apply_motion_blur()
	
	
# Spawns new vehicles.
func _spawn():
	if last_spawn_y - player.position.y > spawn_distance:
		last_spawn_y = player.position.y
		_spawn_vehicle(rand_array([
			[8, car_scene], 
			[2, taxi_scene],
			[4, mini_truck_scene],
			[3, mini_van_scene],
			[1, truck_scene],
			[1, ambulance_scene],
			[1, viper_scene],
			]))
			

# Applies motion blur to the background based on the player's speed.
func _apply_motion_blur():
	var strength = player.get_speed() * blur_factor * 0.001
	background.set_shader_param("strength", strength)
			

func _spawn_vehicle(scene):
	var vehicle = scene.instance()
	var lane = rng.randi_range(0, 3)
	var y = Global.get_screen_bottom() + 50 if vehicle.starts_behind else Global.get_screen_top() - 50
	vehicle.position = Vector2(x_lanes[lane], y)
	vehicle.linear_velocity *= rng.randf_range(0.85, 1.15)
	add_child(vehicle)
	

func rand_array(array):
	# arrays must be [weight, value]
	# Source: https://pastebin.com/HhdBuUzT
	
	var sum_of_weights = 0
	for t in array:
		sum_of_weights += t[0]
	
	var x = rng.randf() * sum_of_weights
	
	var cumulative_weight = 0
	for t in array:
		cumulative_weight += t[0]
		
		if x < cumulative_weight:
			return t[1]
