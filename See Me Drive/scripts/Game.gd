extends Node

export var spawn_distance = 300
export var spawn_chance = 0.7
export var available_lanes = 3
export var blur_factor = 0.3
export var expected_max_speed = 600
export var expected_collision_interval = 30
export var star_spawn_distance = 1000

const x_lanes = [132, 203, 278, 350]

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
onready var star_scene = load("res://scenes/Star.tscn")
onready var rng = RandomNumberGenerator.new()

var last_spawn_y
var screen_height = ProjectSettings.get_setting("display/window/size/height")
var screen_top
var screen_bottom
var time_since_collision = 0
var last_star_spawn_y
var next_star_spawn_distance = star_spawn_distance


func _ready():
	rng.randomize()
	last_spawn_y = player.position.y
	last_star_spawn_y = player.position.y
	

func _process(delta):
	_spawn()
	_spawn_star()
	_apply_motion_blur()
	update_difficulty(delta)
	
	
# Spawns new vehicles.
func _spawn():
	if last_spawn_y - player.position.y > spawn_distance:
		last_spawn_y = player.position.y
		if rand_array([[spawn_chance, true], [1 - spawn_chance, false]]):
			_spawn_vehicle(rand_array([
				[8, car_scene], 
				[2, taxi_scene],
				[4, mini_truck_scene],
				[3, mini_van_scene],
				[1, truck_scene],
				[1, ambulance_scene],
				[1, viper_scene],
				]))


func _spawn_star():
	if last_star_spawn_y - player.position.y > next_star_spawn_distance:
		last_star_spawn_y = player.position.y
		var star = star_scene.instance()
		var y = Global.get_screen_top() - 50
		var x = x_lanes[rng.randi_range(0, len(x_lanes)-1)]
		star.position = Vector2(x, y)
		add_child(star)
		
		next_star_spawn_distance = rng.randi_range(
			star_spawn_distance * 0.5, star_spawn_distance * 1.5)


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
	if len(x_lanes) - len(lanes) >= available_lanes:
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


func update_difficulty(delta):
	spawn_chance = max(min(player.max_speed / expected_max_speed, 0.5), 1.0)
	time_since_collision += delta
	if time_since_collision > expected_collision_interval:
		player.max_speed_acceleration = min(player.max_speed_acceleration + 1, 10)
		time_since_collision = 0


# Handles collision logic to update difficulty.
func new_collision():
	player.max_speed_acceleration = max(player.max_speed_acceleration - 1, 2)


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
