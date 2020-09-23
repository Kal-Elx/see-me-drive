extends RigidBody2D


func _break():
	linear_damp = 2


func _on_Car_body_entered(body):
	_break()
