# Player health state machine

extends "res://state_machine.gd"
onready var parent = get_parent()

func _init():
	add_state('ok')
	add_state('damage')
	add_state('heal')
	add_state('poof')

func _ready():
	set_state(states.ok)
	
func _state_logic(_delta):
	match state:
		states.ok:
			pass
		states.damage:
			parent.take_damage(_delta)
		states.heal:
			parent.heal(_delta)
			parent.update_health_ui()

func _get_transition(_delta):
	match state:
		states.ok:
			print('in light: ', parent.is_in_light())
			if parent.is_in_light() == true:
				print('oh no, light')
				return states.damage
		states.heal:
			if parent.is_in_light():
				return states.damage
			if parent.health >= 100:
				return states.ok 
		states.damage:
			if !parent.is_in_light():
				return states.heal
			if parent.health <= 0:
				return states.poof
	pass

func _enter_state(new_state, _old_state):
	print('now entering ', new_state)
	if new_state == states.ok:
		print('ok')
		parent.face.play('happy')
	if new_state == states.damage:
		print('damage!')
		parent.face.play('oh-no')
	if new_state == states.heal:
		print('healing')
		parent.face.play('oh-no')
