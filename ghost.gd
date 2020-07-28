extends KinematicBody2D

# KNOBS!
# To make any variable editor-adjustable,
# export it; provide a default value, a type, or both

# Motion
export (int) var speed = 300
export (float) var friction = 0.04
export (float) var acceleration = 0.1

# Damage/healing
export (float) var health_decay_rate = 25
export (float) var health_decay_delay = 0
export (float) var health_recharge_rate = 1
export (float) var health_recharge_delay = 0

# Velocity is for physics; to change ghost speed, edit the speed var
var velocity = Vector2.ZERO

# Statuses
# Maybe we treat these as states...
var in_light = false
var time_in_light = 0
var health = 100

func get_input(_delta):
	var input_velocity = Vector2.ZERO
	
	if Input.is_action_pressed("boo"):
		print('boo pressed')
		if current_state == state.IDLE:
			boo()
		if current_state == state.MOVING:
			set_current_state(state.IDLE)
			boo()
		if current_state == state.HAUNTING:
			active_hauntable.onBoo()
			
	if Input.is_action_pressed("haunt"):
		print('haunt pressed')
		if current_state == state.READY_TO_HAUNT:
			haunt(selected_hauntable)
		
	
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
			set_current_state(state.IDLE)
		else:
			$body/torso.play('moving')
			$body/face.position.x = 30.0
			set_current_state(state.MOVING)
	else:
		# If there's no input, slow down to (0, 0)
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
		$body/torso.play('default')
		$body/face.position.x = 10.0
		set_current_state(state.IDLE)
		
	velocity = move_and_slide(velocity)


# This gets called basically every frame	
func _physics_process(_delta):
	get_input(_delta)
	
	# Show/hide "!"
	if (in_light):
		$body/reaction.visible = true
		take_damage(_delta)
	else:
		$body/reaction.visible = false
		if (health < 100):
			heal(_delta)
	
	if (health < 100):
		$healthWheel.visible = true
	else:
		$healthWheel.visible = false
				
	var rounded_health = round(health)
	$health.text = min(100, rounded_health) as String
	$healthWheel.value = min(100, health)


func take_damage(_delta):
	if (health > 0):
		health = health -  (_delta * health_decay_rate)
#
func heal(_delta):
	if (health < 100):
		health = health + (_delta + health_recharge_rate)
#
func on_light_entered():
	$body/face.play("oh-no")
	$body/face.playing = true
		
func on_light_exited():
	$body/face.play("happy")
	$body/face.playing = true
#
func onBoo():
	# add conditionals here to make sure we are in a boo-ready state
	print('boo!')
	$body/face.play('boo')
	$body/face.playing = true

func onHaunt():
	# add conditionals here to check for nearby hauntable
	print('haunt?')


func _ready():
	$body/bottom.play('default')
	$body/torso.play('default')
	$body/face.play('happy')
