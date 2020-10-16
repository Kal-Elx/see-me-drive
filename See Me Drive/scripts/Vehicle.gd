extends RigidBody2D

export var speed = 100
export var break_power = 2
export var starts_behind = false
export var wrong_direction = false

onready var player = get_node("/root/Game/Player")

var enter_counter = 0
var exit_counter = 0
var remove = false
var time_since_remove = 0
var time_not_on_screen = 0
var screen_height = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	if (starts_behind):
		linear_velocity = Vector2(0, -(player.max_speed + speed))
	elif wrong_direction:
		linear_velocity = Vector2(0, speed)
		rotation = PI
	else:
		linear_velocity = Vector2(0, -speed)
	gravity_scale = 0
	linear_damp = 0
	contacts_reported = 1
	contact_monitor = true
	bounce = 1
	
	
func _process(delta):
	# Remove vehicles that have left the screen.
	if (position.y > Global.get_screen_bottom() + 100 or 
		position.y < Global.get_screen_top() - 100):
		queue_free()


func _break():
	linear_damp = break_power


func _on_collision(body):
	_break()
