extends KinematicBody2D

export var speed = 300;
export var handling = 4; # Factor for how fast the car can turn.
export var drive_towards_hold_pos = true
export var vertical_speed_preserved_in_turn = 0.0 # float 0-1. 

var direction = Vector2()
var velocity = Vector2()
var min_touch_from_car = ProjectSettings.get_setting("display/window/size/width") / 4
var touching = false # If the user is touching the screen.
var touch_pos = Vector2() # Where the user is touching the screen.

func _ready():
	_drive_straight()


func _process(delta):
	if touching:
		_steer(touch_pos)
		if (drive_towards_hold_pos):
			touch_pos.y -= speed * delta


func _physics_process(delta):
	# Rotate player
	rotation = Global.fromYAxis(velocity.angle())
	
	# Calculate new velocity
	velocity += (direction - velocity) * handling * delta
	var motion = velocity * delta
	move_and_collide(motion)


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
