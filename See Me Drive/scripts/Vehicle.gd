extends RigidBody2D

export var speed = 100
export var break_power = 2
export var starts_behind = false
export var wrong_direction = false

onready var player = get_node("/root/Game/Player")
onready var camera = get_node("/root/Game/Player/Camera2D")
onready var sound = get_child(2)

var screen_height = ProjectSettings.get_setting("display/window/size/height")
var collided = false
var init_volume


func _ready():
	gravity_scale = 0
	linear_damp = 0
	contacts_reported = 1
	contact_monitor = true
	bounce = 1
	if starts_behind:
		pass # Handled in process.
	elif wrong_direction:
		linear_velocity = Vector2(0, speed)
		rotation = PI
		bounce = 0.5
	else:
		linear_velocity = Vector2(0, -speed)
		
	if sound != null:
		init_volume = sound.volume_db
	
	
func _process(delta):
	# Remove vehicles that have left the screen.
	if (position.y > Global.get_screen_bottom() + 100 or 
		position.y < Global.get_screen_top() - 100):
		queue_free()
		
	if starts_behind and not collided:
		linear_velocity = Vector2(0, -(player.max_speed + speed))
		
	if sound != null:
		var volume_factor = (player.position.y - position.y) / (screen_height/2 - camera.offset.y)
		volume_factor = max(min(volume_factor, 1), 0)
		sound.volume_db = init_volume - 20 * volume_factor


func _break():
	linear_damp = break_power


func _on_collision(body):
	_break()
	collided = true
