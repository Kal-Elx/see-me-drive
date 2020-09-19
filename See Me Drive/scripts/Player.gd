extends KinematicBody2D

export var turn_speed = 10;
export var speed_factor = 500;

var velocity = Vector2()
var direction = Vector2()
var min_touch_from_car = ProjectSettings.get_setting("display/window/size/width") / 8

func _ready():
	# Straighten player.
	direction = Vector2(position.x, 0)
	
	
func _physics_process(delta):
	# Turn (rotate) player 
	var rotation_dir = Global.fromYAxis(get_angle_to(direction))
	rotation += rotation_dir * turn_speed * delta
	
	# Move in turned direction
	var turn_dir = -Global.fromYAxis(get_angle_to(Vector2(position.x, 0)))
	velocity.x = turn_dir * speed_factor * delta
	var motion = velocity
	move_and_collide(motion)

	
func _unhandled_input(event):
	if event is InputEventScreenDrag:
		# Drive towards touched point.
		direction = event.position
		# Should not be able to turn backwards.
		direction.y = min(position.y - min_touch_from_car, event.position.y)
	
	# If user released screen.
	if event is InputEventScreenTouch and !event.is_pressed():
		# Straighten player.
		direction = Vector2(position.x, 0)
