# Hauntable

extends KinematicBody2D
export var can_move = false
export var can_act = true

# Motion - just for testing rn
export (int) var speed = 500
export (float) var friction = 0.1
export (float) var acceleration = 0.2
var velocity = Vector2.ZERO

var root

enum state {
	IDLE,
	SELECTED,
	HAUNTED,
	ACTING,
	MOVING
}

var current_state = state.IDLE


# Called when the node enters the scene tree for the first time.
func _ready():
	root = get_parent()
	set_process_input(false)
	set_physics_process(false)
	
func handle_movement():
	if ( Input.is_action_just_pressed('move_right') or
		Input.is_action_just_pressed('move_left')):
		set_current_state(state.MOVING)
	
	if ( Input.is_action_just_released('move_right') or
		 Input.is_action_just_released('move_left')):
		set_current_state(state.HAUNTED)
	
	var input_velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_velocity.x += 1
		$AnimatedSprite.scale.x = 1
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= 1
		$AnimatedSprite.scale.x = -1
			
	input_velocity = input_velocity.normalized() * speed
	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)

# helper for checking if something's our ghost,
# in case this logic needs to change later
# should probably use collision layers instead
func is_player(body):
	return 'health' in body

# not sure if keeping this but maybe?	
# state change method - there may be a better way to do this?
func set_current_state(new_state):
	current_state = new_state
	match current_state:
		state.IDLE:
			print('idle')
		state.SELECTED:
			print('selected')
		state.HAUNTED:
			print('haunted')
		state.MOVING:
			print('moving')
		state.ACTING:
			print('acting')

# Core input handler
func _input(event):
	if Input.is_action_just_pressed('haunt'):
		onHaunt()
	if Input.is_action_just_pressed('boo') and can_act:
		onBoo()
#
func _physics_process(_delta):
	if can_move:
		handle_movement()
	
# these need to talk to the parent scene to update active_hauntable
func _on_Area2D_body_entered(body):
	if current_state != state.IDLE or !is_player(body):
		return
	body.onHauntableApproach(self)
	set_current_state(state.SELECTED)

func _on_Area2D_body_exited(body):
	if current_state != state.SELECTED or !is_player(body):
		return
	body.onHauntableLeave(self)
	set_current_state(state.IDLE)

func activate():
	set_physics_process(true)
	set_process_input(true)
	$Camera2D.current = true
	set_current_state(state.HAUNTED)

func deactivate():
	set_physics_process(false)
	set_process_input(false)
	$Camera2D.current = false
	set_current_state(state.IDLE)

func onBoo():
	$Label.visible = true
	
func onHaunt():
	deactivate()
	root.active_hauntable = null
