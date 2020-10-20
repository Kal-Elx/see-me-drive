extends KinematicBody2D

export var max_speed = 300.0
export var min_speed = 100.0
export var acceleration = 50
export var max_speed_acceleration = 5 # Pixels per second
export var handling = 1.0/50 # Factor for how fast the car can turn.
export var off_road_break = -50 # Speed loss / sec off road
export var max_speed_loss_off_road = 10 # Max speed loss / sec off road
export var drive_towards_hold_pos = true
export var vertical_speed_preserved_in_turn = 0.0 # float 0-1. 
export var max_damage_outline = 4.0 # Width of damage outline
export var outline_speed = 20 # Speed of outline
export var collision_cool_down = 1
export var speed_limit = 995

var direction = Vector2.UP
var velocity = Vector2.UP
var speed = 0
var init_acceleration = acceleration # Save init acceleration.
var init_max_speed_acceleration = max_speed_acceleration # Save init.
var min_touch_from_car = ProjectSettings.get_setting("display/window/size/width") / 4
var touching = false # If the user is touching the screen.
var touch_pos = Vector2() # Where the user is touching the screen.
var curr_damage_outline = 0
var outline_dir = 1
var taking_damage = false
var on_road = true
var time_since_vibrate = 0
var reached_min_speed = 0
var curr_collision_cool_down = 0

onready var game = get_parent()
onready var init_max_speed = max_speed
onready var player_sprite = get_child(1)
onready var left_boundary = get_owner().find_node('Road').get_child(1).position.x
onready var right_boundary = get_owner().find_node('Road').get_child(2).position.x


func _ready():
	_drive_straight()
	

func _process(delta):
	if touching:
		if not reached_min_speed and speed > min_speed:
			reached_min_speed = true
		
		# Accelerate to max speed.
		var acc = acceleration if on_road else off_road_break
		speed = min(max(min(max_speed, speed + acc * delta), 
					min_speed if reached_min_speed else 0), speed_limit)
		
		# Steer player.
		_steer(touch_pos)
		if drive_towards_hold_pos:
			touch_pos.y -= speed * delta
			
		_update_max_speed(delta)
	
	if taking_damage or curr_damage_outline > 0:
		_damage_highlight(delta)
	
	_handle_off_road(delta)
	
	curr_collision_cool_down = max(curr_collision_cool_down - delta, 0)


func _physics_process(delta):
	# Rotate player.
	rotation = Global.fromYAxis(velocity.angle())
	
	# Calculate new velocity.
	if speed > 0:
		velocity += (direction - velocity) * speed * handling * delta
		move_and_collide(velocity * delta)


func _unhandled_input(event):
	if event is InputEventScreenDrag or event is InputEventScreenTouch and event.is_pressed():
		touching = true
		touch_pos = event.position

	# If user released screen.
	if event is InputEventScreenTouch and !event.is_pressed():
		touching = false
		_drive_straight()
		

func _steer(touch_pos):
	var player_screen_pos = get_global_transform_with_canvas().get_origin()
	
	# Should not be able to turn backwards.
	var drive_towards_pos = Vector2(touch_pos.x, 
	min(player_screen_pos.y - min_touch_from_car, touch_pos.y))
	
	# Set direction.
	direction = (drive_towards_pos - player_screen_pos).normalized() * speed
	
	# Presarve vertical speed while turning.
	direction.y -= (speed + direction.y) * vertical_speed_preserved_in_turn


func _drive_straight():
	direction = Vector2(0, -1).normalized() * speed


func _on_collision(body):
	if body.is_in_group('obstacles'):
		if curr_collision_cool_down == 0:
			speed *= 0.5
			max_speed *= 0.8
		outline_dir = 1
		_indicate_damage()
		curr_collision_cool_down = collision_cool_down # Start cool down
		game.new_collision()


func _update_max_speed(delta):
	if not on_road:
		max_speed -= delta * max_speed_loss_off_road
	elif speed >= floor(max_speed):
		max_speed += delta * max_speed_acceleration
	
	# Max acceeleration should never drop below the initialized max speed.
	max_speed = max(max_speed, init_max_speed)


func _indicate_damage():
	Input.vibrate_handheld(200) # Vibrate phone
	taking_damage = true # Will highlight the player
	

func _stop_indicating_damage():
	curr_damage_outline = 0
	outline_dir = 1
	taking_damage = false


func _damage_highlight(delta):
	curr_damage_outline += delta * outline_speed * outline_dir
	player_sprite.material.set_shader_param("outline_width", curr_damage_outline)	
	if curr_damage_outline > max_damage_outline:
		outline_dir = -1
	elif curr_damage_outline <= 0:
		outline_dir = 1
		if on_road:
			_stop_indicating_damage()


func _handle_off_road(delta):
	if position.x < left_boundary or position.x > right_boundary:
		if on_road:
			_indicate_damage()
		on_road = false
		time_since_vibrate += delta
		time_since_vibrate += delta
		if time_since_vibrate >= 0.5:
			Input.vibrate_handheld(200)
			time_since_vibrate = 0
	else:
		on_road = true
		time_since_vibrate = 0
	
	
func get_speed():
	return velocity.length() if speed != 0 else 0
	

# Called from Pause when the game is resumed.
func wake_up():
	player_sprite.material.set_shader_param("outline_color", Color.red)
	


func _on_collected_point(area):
	if area.is_in_group('star'):
		area.queue_free()
