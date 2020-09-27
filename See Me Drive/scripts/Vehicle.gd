extends RigidBody2D

export var speed = 100
export var break_power = 2

func _ready():
	linear_velocity = Vector2(0, -speed)
	gravity_scale = 0
	linear_damp = 0
	contacts_reported = 1
	contact_monitor = true
	bounce = 1

func _break():
	linear_damp = break_power


func _on_collision(body):
	_break()
