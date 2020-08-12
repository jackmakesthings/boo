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
export (float) var health_decay_delay = 0 # not implemented yet
export (float) var health_recharge_rate = 1
export (float) var health_recharge_delay = 0 # not implemented yet

# Track whether we're close enough to haunt something
var nearby_hauntable = null

# Velocity is for physics; to change ghost speed, edit the speed var
var velocity = Vector2.ZERO

# Status info
var in_light = false
var time_in_light = 0
var health = 100

var allow_boo = true # this is a little questionable, refactor?

enum motion_states { IDLE, MOVING }
enum health_states { OK, DAMAGE, HEAL }
var motion_state = motion_states.IDLE
var health_state = health_states.OK

# cache some node paths in case they change later
onready var face = $body/face
onready var reaction = $body/reaction
onready var body_bg = $body/bg
onready var torso = $body/bg/torso
onready var bottom = $body/bg/bottom
onready var particles = $body/bg/Particles2D
onready var camera = $Camera2D


func set_motion_state(new_state):
	if new_state == motion_state: return
	motion_state = new_state
	match new_state:
		motion_states.IDLE:
			face.position.x = 10.0
			torso.play('default')
		motion_states.MOVING:
			face.position.x = 30.0
			torso.play('moving')

func set_health_state(new_state):
	if new_state == health_state: return
	health_state = new_state
	match new_state:
		health_states.OK:
			face.play('happy')
			reaction.visible = false
		health_states.DAMAGE:
			face.play('oh-no')
			reaction.visible = true
		health_states.HEAL:
			face.play('happy') # replace w/heal-face
			reaction.visible = false
				
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
	if Input.is_action_pressed("move_down"): input_velocity.y += 1
	if Input.is_action_pressed("move_up"): input_velocity.y -= 1
			
	input_velocity = input_velocity.normalized() * speed

	if input_velocity.length() > 0:
		set_motion_state(motion_states.MOVING)
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
		set_motion_state(motion_states.IDLE)
	velocity = move_and_slide(velocity)


# This gets called basically every frame	
func _physics_process(_delta):
	handle_movement(_delta)
	
	# Show/hide "!"
	if (in_light):
		set_health_state(health_states.DAMAGE)
	else:
		if (health < 100):
			set_health_state(health_states.HEAL)
		else:
			set_health_state(health_states.OK)
	
	match health_state:
		health_states.DAMAGE:
			take_damage(_delta)
		health_states.HEAL:
			heal(_delta)
		health_states.OK:
			pass

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
	body_bg.modulate.a = .7 + (1 - (rounded_health/100))

func take_damage(_delta):
	if (health > 0):
		health = health -  (_delta * health_decay_rate)
#
func heal(_delta):
	health = health + (_delta + health_recharge_rate)


# These conditionals will probably get more robust	
func canBoo():
	return health >= 100 and allow_boo

func canHaunt():
	return health >= 100 and nearby_hauntable


# Proximity listeners	
func onHauntableApproach(hauntable):
	nearby_hauntable = hauntable

func onHauntableLeave(_hauntable):
	nearby_hauntable = null

func on_light_entered():
	pass

func on_light_exited():
	pass


# Action input handlers
func onBoo():
	if canBoo():
		allow_boo = false # prevent multiple boo spams
		face.play('boo')
		yield(face, "animation_finished")
		face.play('happy')
		allow_boo = true
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
	camera.current = true
	visible = true

func deactivate():
	set_physics_process(false)
	set_process_input(false)
	camera.current = false
	visible = false
	
func _ready():
	set_motion_state(motion_states.IDLE)
	set_health_state(health_states.OK)
	particles.emitting = true
	bottom.play('default')
