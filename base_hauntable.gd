# Static Hauntable - boo only, no motion
# Hauntables merit a refactor but I need to read more first

extends StaticBody2D
var root

enum state {
	IDLE,
	SELECTED,
	HAUNTED,
	ACTING
}

var current_state = state.IDLE


# Called when the node enters the scene tree for the first time.
func _ready():
	$hauntbox.connect("body_entered", self, "_on_hauntbox_entered")
	$hauntbox.connect("body_exited", self, "_on_hauntbox_exited")
	
	root = get_parent()
	set_process_input(false)
	set_physics_process(false)
	
func handle_movement():
	pass

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
			modulate = '#fff'
			print('idle')
		state.SELECTED:
			modulate = '#7b43e9';
			print('selected')
		state.HAUNTED:
#			modulate = '#fff'
			modulate = '#7b43e9';
			print('haunted')
		state.ACTING:
			print('acting')

# Core input handler
func _input(_event):
	if Input.is_action_just_pressed('haunt'):
		onHaunt()
	if Input.is_action_just_pressed('boo'):
		onBoo()
#
func _physics_process(_delta):
	pass
	
# these need to talk to the parent scene to update active_hauntable
func _on_hauntbox_entered(body):
	if current_state != state.IDLE or !is_player(body):
		return
	body.onHauntableApproach(self)
	set_current_state(state.SELECTED)

func _on_hauntbox_exited(body):
	if current_state != state.SELECTED or !is_player(body):
		return
	body.onHauntableLeave(self)
	set_current_state(state.IDLE)

func activate():
	set_process_input(true)
	set_current_state(state.HAUNTED)

func deactivate():
	set_process_input(false)
	set_current_state(state.IDLE)

func onBoo():
	print('boo!')
#	$Label.visible = true
	
func onHaunt():
	deactivate()
	root.active_hauntable = null
