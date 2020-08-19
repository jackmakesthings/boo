extends 'res://hauntable.gd'

func onBoo():
	print('boo!')
	$AnimatedSprite.play('scare')
	$scarebox.fire()
