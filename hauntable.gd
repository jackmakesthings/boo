# Hauntable

extends KinematicBody2D
export var can_move = false
export var can_act = true

enum state {
	IDLE,
	SELECTED,
	HAUNTED,
	ACTIVE,
	MOVING
}

var current_state = state.IDLE

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# helper for checking if something's our ghost,
# in case this logic needs to change later
func is_player(body):
	return body.has_method('haunt')

# not sure if keeping this but maybe?	
# state change method - there may be a better way to do this?
func set_current_state(new_state):
	current_state = new_state
	
	match current_state:
		state.IDLE:
			print('idle')
		state.SELECTED:
			print('selected')
		state.ACTIVE:
			print('active')
		state.HAUNTED:
			print('haunted')
		state.MOVING:
			print('moving')
		
func _input(event):
	pass


# these need to talk to the parent scene to update active_hauntable
func _on_Area2D_body_entered(body):
	if current_state == state.IDLE && is_player(body):
		set_current_state(state.SELECTED)
		body.onHauntableApproach(self)

func _on_Area2D_body_exited(body):
	if current_state == state.SELECTED && is_player(body):
		set_current_state(state.SELECTED)
		body.onHauntableLeave(self)
		
# methods to reference from the ghost

func onBoo():
	# conditionals here for whether this hauntable "can_act"
	print('spoooooky!')

func onHaunt():
	# this should universally be an "unhaunt" which updates the scene
	pass

func onMove():
	# still not sure how exactly to pass the inputs here
	# put conditionals for can_move, then movement logic if true
	# maybe velocity or input gets passed as a param here?
	pass