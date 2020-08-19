extends KinematicBody2D

# Motion
export (int) var speed = 300
export (float) var friction = 0.04
export (float) var acceleration = 0.1
var velocity = Vector2.ZERO


func handle_movement(_delta):
	var input_velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"): 
		input_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= 1 
	if Input.is_action_pressed("move_down"): input_velocity.y += 1
	if Input.is_action_pressed("move_up"): input_velocity.y -= 1
			
	input_velocity = input_velocity.normalized() * speed

	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)


# This gets called basically every frame	
func _physics_process(_delta):
#	handle_movement(_delta)
	pass
