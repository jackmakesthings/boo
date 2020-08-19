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

func _init():
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
