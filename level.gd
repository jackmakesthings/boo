extends Node2D

var active_hauntable setget set_active_hauntable, get_active_hauntable
onready var player = $ghost
var holp = Vector2.ZERO

func get_active_hauntable():
	return active_hauntable


func set_active_hauntable(hauntable):
	# hauntable is null, restore controls to the ghost
	if (!hauntable):
		holp = active_hauntable.get_node('origin').global_position
		active_hauntable.get_node("Camera2D").current = false
		
		player.set_physics_process(true)
		player.set_process_input(true)
		player.global_position = holp
		player.get_node("Camera2D").current = true
		player.visible = true
	
	# hauntable is set, delegate controls	
	else:
		player.set_physics_process(false)
		player.set_process_input(false)
		player.get_node("Camera2D").current = false
		player.visible = false
		
		hauntable.activate()
	
	active_hauntable = hauntable
	print(active_hauntable)
