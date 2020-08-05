extends Control

func new_game():
	get_tree().change_scene("res://scenes/house.tscn")

# these do the same for now, just as placeholder actions
func continue():
	get_tree().change_scene("res://scenes/house.tscn")

func show_options():
	get_tree().change_scene("res://scenes/Options.tscn")
