extends Node

var states = {}
var state = null
var prev_state = null

func _state_logic(_delta):
	pass

func _get_transition(_delta):
	pass

func _enter_state(_new_state, _old_state):
	pass

func _exit_state(_old_state, _new_state):
	pass

func set_state(new_state):
	prev_state = state
	state = new_state

	if prev_state:
		_exit_state(prev_state, new_state)
	if new_state:
		print('now entering state ', new_state)
		_enter_state(new_state, prev_state)

func add_state(new_state):
	states[new_state] = states.size() # like a reverse enum

func _physics_process(delta):
	if state:
		print(state)
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition:
			print('got transition!')
			set_state(transition)
