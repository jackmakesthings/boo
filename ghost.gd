extends KinematicBody2D
var root

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

# Track whether we're close enough to haunt something
var nearby_hauntable = null

# Velocity is for physics; to change ghost speed, edit the speed var
var velocity = Vector2.ZERO

# Statuses
# Maybe we treat these as states...
var in_light = false
var time_in_light = 0
var health = 100

enum state {
	IDLE,
	MOVING,
	READY_TO_HAUNT,
	HAUNTING,
	POOF
}

var current_state = state.IDLE
# not sure i need this to be a func but couldn't hurt

func set_current_state(state):
	current_state = state
	
func _enter_tree():
	root = get_parent()
	
func _input(event):
	if Input.is_action_just_pressed('boo'):
		onBoo()
	if Input.is_action_just_pressed('haunt'):
		onHaunt()

func handle_movement(_delta):
	var input_velocity = Vector2.ZERO

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
	handle_movement(_delta)
	
	# Show/hide "!"
	if (in_light):
		$body/reaction.visible = true
		take_damage(_delta)
	else:
		$body/reaction.visible = false
		if (health < 100):
			heal(_delta)
	
	if (health < 100):
		$health.visible = true
		$healthWheel.visible = true
	else:
		$health.visible = false
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

# These conditionals will probably get more robust	
func canBoo():
	return health >= 100

func canHaunt():
	return health >= 100 and nearby_hauntable
	
func onHauntableApproach(hauntable):
	nearby_hauntable = hauntable

func onHauntableLeave(hauntable):
	nearby_hauntable = null

func onBoo():
	if canBoo():
		$body/face.play('boo')
		$body/face.playing = true
	else:
		print("can't boo right now!")

func onHaunt():
	if canHaunt():
		root.active_hauntable = nearby_hauntable
	else:
		print("can't haunt right now")
	
func _ready():
	$body/bottom.play('default')
	$body/torso.play('default')
	$body/face.play('happy')
