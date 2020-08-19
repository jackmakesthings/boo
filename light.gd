extends Node2D

export (NodePath) var player
onready var rays = find_node('rays').get_children()
onready var target = get_node(player)

func _physics_process(_delta):
	try_to_hit(target)
		
func ghost_in_range():
	return $Area2D.get_overlapping_bodies().has(target)

func try_to_hit(t):
	var is_hitting = false
	for ray in rays:
		if ray.is_colliding() and ray.get_collider() == t:
			if 'light_sources' in t and !t.light_sources.has(self.name):
				t.light_sources.append(self.name)
			is_hitting = true
			continue
		
	if !is_hitting:
		if 'light_sources' in t and t.light_sources.has(self.name):
			t.light_sources.erase(self.name)

# Used to use area checking for the in_light state, but we have evolved!
## Still might want these for something later...
#func _on_Area2D_body_entered(body):
#	if 'light_sources' in body:
#		target = body
#	pass
#	body.in_light = true
#	body.on_light_entered()

#func _on_Area2D_body_exited(body):
#	if 'light_sources' in target and target.light_sources.has(self):
#			target.light_sources.erase(self)
#			print(target.light_sources)
#	pass
#	body.in_light = false
#	body.on_light_exited()
