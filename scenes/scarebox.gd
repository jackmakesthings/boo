extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var targets
var space_state


export var scare_level = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func clear_shot(target: Node):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, target.global_position, [self], collision_mask)
	return [(result.collider == target), result.collider]

# This should be called in the hauntable's onBoo method
func fire():
	var scare_succeeded = false
	space_state = get_world_2d().direct_space_state
	targets = get_overlapping_bodies()
	for target in targets:
		if target.has_method('onScare'):
			if clear_shot(target)[0] == true:
				target.onScare(scare_level, self)
				scare_succeeded = true
			else:
				print('nope, hit ' + clear_shot(target)[1].get_name())
			
	if !scare_succeeded:
		print('not quite')
			
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	targets = get_overlapping_bodies()
#	pass
