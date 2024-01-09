extends Control

func _ready():
	var data_file = File.new()
	# check if file exists in system
	var save_names = ["user://save1Data.txt", "user://save2Data.txt", "user://save3Data.txt"]
	var buttons = [$MenuVBox/Save1, $MenuVBox/Save2, $MenuVBox/Save3]
	
	# loops through save names and checks if it exists
	for name in save_names:
		var save_index = int(name[11]) - 1
		# update button label if there is an existing save
		if not data_file.file_exists(name):
			buttons[save_index].text = "NEW SAVE " + name[11]
		else:
			buttons[save_index].text = "SAVE " + name[11]

func _on_Back_pressed():
	SceneTransition.change_scene('res://main_menu/MainMenu.tscn')

# Save buttons
func _on_Save1_pressed():
	Globals.save_profile = 1
	SceneTransition.change_scene('res://load/Load.tscn')
func _on_Save2_pressed():
	Globals.save_profile = 2
	SceneTransition.change_scene('res://load/Load.tscn')
func _on_Save3_pressed():
	Globals.save_profile = 3
	SceneTransition.change_scene('res://load/Load.tscn')
	

			
		
	
