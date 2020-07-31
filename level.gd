extends Node2D

var active_hauntable setget set_active_hauntable
onready var player = $ghost
var holp = Vector2.ZERO

func set_active_hauntable(hauntable):
	# hauntable is null, restore controls to the ghost
	if (!hauntable):
		holp = active_hauntable.get_node('origin').global_position
		active_hauntable.deactivate()
		player.activate(holp)
	
	# hauntable is set, delegate controls	
	else:
		player.deactivate()
		hauntable.activate()
	
	active_hauntable = hauntable
	print(active_hauntable)
