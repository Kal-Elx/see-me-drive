extends Node

export var spawn_distance = 100
export var blur_factor = 0.3

const x_lanes = [140, 208, 280, 358]

var last_spawn_y
var rng = RandomNumberGenerator.new()
var screen_height = ProjectSettings.get_setting("display/window/size/height")
var screen_top
var screen_bottom

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
	_spawn()
	_apply_motion_blur()
	
	
# Spawns new vehicles.
func _spawn():
	if last_spawn_y - player.position.y > spawn_distance:
		last_spawn_y = player.position.y
		
		# Spawn a third of the times spawn distance is reached.
		if rng.randi_range(1, 3) % 3 == 0:
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
	# Update screen cords
	screen_top = Global.get_screen_top()
	screen_bottom = Global.get_screen_bottom()
	
	var vehicle = scene.instance()
	var lanes = lanes_to_place(vehicle)
	if len(lanes) < 2: # There must always be a gap for the player.
		return
	var lane = lanes[rng.randi_range(0, len(lanes)-1)] # Random possible lane.
	var y = screen_bottom + 50 if vehicle.starts_behind else screen_top - 50 #
	vehicle.position = Vector2(x_lanes[lane], y)
	vehicle.linear_velocity *= rng.randf_range(0.85, 1.15)
	add_child(vehicle)


func lanes_to_place(vehicle):
	var res = []
	for i in range(4):
		var possible = true
		for v in get_tree().get_nodes_in_group("obstacles"):
			if to_close(vehicle, v, i):
				possible = false
				break;
		if possible:
			res.append(i)
	return res


# Is the new vehicle to close to the given vehicle.
func to_close(new, to, lane):
	# If not in same lanes.
	if abs(to.position.x - x_lanes[lane]) > 20:
		return false
	var from = screen_bottom if new.starts_behind else screen_top
	var min_dist = 100
	if new.starts_behind or to.starts_behind:
		min_dist = screen_height
	elif new.wrong_direction or to.wrong_direction:
		min_dist = screen_height * 0.5
	return abs(to.position.y - from) < min_dist


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
