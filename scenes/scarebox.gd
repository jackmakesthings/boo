extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var targets


export var scare_level = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# This should be called in the hauntable's onBoo method
func fire():
	targets = get_overlapping_bodies()
	for target in targets:
		if target.has_method('onScare'):
			target.onScare(2, self)
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
