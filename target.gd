extends KinematicBody2D
const UP = Vector2(0, -1)
export var speed = 200
var current_speed = speed
var is_turning = false

var motion = Vector2()
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var dir = right

func onScare(scare_amount, source):
	print('scared by ', source.get_name())
	$Label.visible = true
	set_physics_process(false)
	
	$body/torso.play('scared')
	$body/legs.play('scared')
	$body/head.play('scared')
	$body/head.position = Vector2(54, -170)
	$body/arm_front.scale.y = -1
	$body/arm_back.rotation_degrees = -140
	pass

func _ready():
	$body/legs.play('walk')

func _physics_process(delta):
	motion.y = 0
	motion.x = dir.x * current_speed
	motion = move_and_slide(motion, UP)

	if is_on_wall() and !is_turning:
		is_turning = true
		current_speed = 0
		$body/torso.play('turnaround')
		$body/head.play('turnaround')
		$body/legs.play('turnaround')
		yield($body/legs, 'animation_finished')
		
		dir *= -1
		scale.x *= -1
		$body/torso.play('idle')
		$body/head.play('idle')
		$body/legs.play('walk')
		
		current_speed = speed
		is_turning = false
		
