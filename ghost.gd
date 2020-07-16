extends KinematicBody2D


# KNOBS!
# To make any variable editor-adjustable,
# export it; provide a default value, a type, or both

export (int) var speed = 200
export (float) var friction = 0.04
export (float) var acceleration = 0.1

# Velocity is for physics; to change ghost speed, edit the speed var
var velocity = Vector2.ZERO

# Statuses
var in_light = false
var time_in_light = 0
var health = 100

export (float) var health_decay_rate = .1
export (float) var health_decay_delay = 0
export (float) var health_recharge_rate = .1

func get_input(_delta):
	var input_velocity = Vector2.ZERO
	
	if Input.is_action_pressed("boo"):
		boo()
	
	if Input.is_action_pressed("move_right"):
		input_velocity.x += 1
		$body.scale.x = 1
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= 1
		$body.scale.x = -1
	if Input.is_action_pressed("move_down"):
		input_velocity.y += 1
	if Input.is_action_pressed("move_up"):
		input_velocity.y -= 1
			
	input_velocity = input_velocity.normalized() * speed

	# If there's input, accelerate to the input velocity
	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
		if input_velocity.x == 0:
			$body/torso.play('default')
			$body/face.position.x = 10.0
		else:
			$body/torso.play('moving')
			$body/face.position.x = 30.0
	else:
		# If there's no input, slow down to (0, 0)
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
		$body/torso.play('default')
		$body/face.position.x = 10.0
	velocity = move_and_slide(velocity)
	

# This gets called basically every frame	
func _physics_process(_delta):
	get_input(_delta)
	
	# Show/hide "!"
	if (in_light):
		$body/reaction.visible = true
	else:
		$body/reaction.visible = false
#
	$body/health.text = health as String
#
#func take_damage(_delta):
#	if (health > 0):
#		health = health - (_delta * health_decay_rate)
#
#func heal(_delta):
#	if (health < 100):
#		health = health + (_delta + health_recharge_rate)
#
func on_light_entered():
	print('in')
	$body/face.play("oh-no")
	$body/face.playing = true
		
func on_light_exited():
	print('out')
	$body/face.play("happy")
	
	$body/face.playing = true
#

func boo():
	$body/face.play('boo')
	$body/face.playing = true
#
func _ready():
	$body/bottom.play('default')
	$body/torso.play('default')
	$body/face.play('happy')
