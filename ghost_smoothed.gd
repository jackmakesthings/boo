extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('move_right'):
		if Input.is_action_just_pressed('move_right'):
			velocity.x += 0.25
		else:
			velocity.x += 1
	if Input.is_action_pressed('move_left'):
		if Input.is_action_just_pressed('move_left'):
			velocity.x -= 0.25
		else:
			velocity.x -= 1
	if Input.is_action_pressed('move_down'):
		if Input.is_action_just_pressed('move_down'):
			velocity.y += 0.25
		else:
			velocity.y += 1
	if Input.is_action_pressed('move_up'):
		if Input.is_action_just_pressed('move_up'):
			velocity.y -= 0.25
		else:
			velocity.y -= 1
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
