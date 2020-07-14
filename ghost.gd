extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()
var in_light = false


func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('move_right'):
		velocity.x += 1
	#if Input.is_action_just_pressed('move_right'):
		$CollisionPolygon2D.scale.x =  1.0
		
	if Input.is_action_pressed('move_left'):
		velocity.x -= 1
		$CollisionPolygon2D.scale.x = -1.0
	#if Input.is_action_just_pressed('move_left'):
		
	if Input.is_action_pressed('move_down'):
		velocity.y += 1
	if Input.is_action_pressed('move_up'):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func _physics_process(_delta):
	get_input()
	velocity = move_and_slide(velocity)
	if (in_light):
		$CollisionPolygon2D/reaction.visible = true
	else:
		$CollisionPolygon2D/reaction.visible = false
