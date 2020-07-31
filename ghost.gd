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

# i don't think these are actually the states needed, tbd
enum state {
	IDLE,
	MOVING,
	DAMAGE,
	HEAL,
	READY
#	READY_TO_HAUNT,
#	HAUNTING,
#	POOF
}

# This maybe shouldn't be a state because it overlaps with other stuff
var is_moving = false

var current_state = state.IDLE
# not sure i need this to be a func but couldn't hurt

func set_current_state(new_state):
	if new_state == current_state:
		return
	
	current_state = new_state
	match new_state:
		state.IDLE:
			$body/face.position.x = 10.0
			$body/bg/torso.play('default')
			if health < 100:
				if in_light:
					set_current_state(state.DAMAGE)
				else:
					set_current_state(state.HEAL)
			print('idle')
		state.MOVING:
			$body/bg/torso.play('moving')
			$body/face.position.x = 30.0
			print('moving')
		state.DAMAGE:
			$body/face.play('oh-no')
			print('damage')
		state.HEAL:
			print('heal')
		state.READY:
			$body/bg/bottom.play('default')
			$body/face.play('happy')
			print('ready')
	
func _enter_tree():
	root = get_parent()
	
func _input(event):
	if Input.is_action_just_pressed('boo'):
		onBoo()
	if Input.is_action_just_pressed('haunt'):
		onHaunt()
	
	if (Input.is_action_just_pressed('move_right') or 
	   Input.is_action_just_pressed('move_left') or
	   Input.is_action_just_pressed('move_down') or
	   Input.is_action_just_pressed('move_up')):
		set_current_state(state.MOVING)
	
	if (Input.is_action_just_released('move_right') or 
	   Input.is_action_just_released('move_left') or
	   Input.is_action_just_released('move_down') or
	   Input.is_action_just_released('move_up')):
		set_current_state(state.IDLE)

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
#		if input_velocity.x == 0:
#			set_current_state(state.IDLE)
#		else:
#			set_current_state(state.MOVING)
	else:
		# If there's no input, slow down to (0, 0)
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)


# This gets called basically every frame	
func _physics_process(_delta):
	handle_movement(_delta)
	# Show/hide "!"
	if (in_light):
		$body/reaction.visible = true
		set_current_state(state.DAMAGE)
		take_damage(_delta)
	else:
		$body/reaction.visible = false
		if (health < 100):
			set_current_state(state.HEAL)
			heal(_delta)
		else:
			set_current_state(state.READY)
	update_health_ui()

func update_health_ui():
	if (health < 100):
		$health.visible = true
		$healthWheel.visible = true
	else:
		$health.visible = false
		$healthWheel.visible = false
				
	var rounded_health = round(health)
	$health.text = min(100, rounded_health) as String
	$healthWheel.value = min(100, health)
	$body/bg.modulate.a = .7 + (1 - (rounded_health/100))

func take_damage(_delta):
	if (health > 0):
		set_current_state(state.DAMAGE)
		health = health -  (_delta * health_decay_rate)
#
func heal(_delta):
	set_current_state(state.HEAL)
	health = health + (_delta + health_recharge_rate)


# These conditionals will probably get more robust	
func canBoo():
	return health >= 100

func canHaunt():
	return health >= 100 and nearby_hauntable


# Proximity listeners	
func onHauntableApproach(hauntable):
	nearby_hauntable = hauntable

func onHauntableLeave(_hauntable):
	nearby_hauntable = null

func on_light_entered():
	pass
#	$body/face.play("oh-no")
#	$body/face.playing = true

func on_light_exited():
	pass
#	$body/face.play("happy")
#	$body/face.playing = true


# Action input handlers
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


# Setup and teardown (when switching haunt state)
func activate(holp):
	set_physics_process(true)
	set_process_input(true)
	global_position = holp
	$Camera2D.current = true
	visible = true

func deactivate():
	set_physics_process(false)
	set_process_input(false)
	$Camera2D.current = false
	visible = false
	
func _ready():
	set_current_state(state.READY)
	set_current_state(state.IDLE)
	$body/bg/Particles2D.emitting = true
