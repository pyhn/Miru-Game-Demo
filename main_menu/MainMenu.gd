extends Control


func _on_Play_pressed():
	SceneTransition.change_scene('res://main_menu//SaveSelect.tscn')

func _on_Quit_pressed():
	get_tree().quit()

func _on_Options_pressed():
	SceneTransition.change_scene('res://main_menu/Options.tscn')
