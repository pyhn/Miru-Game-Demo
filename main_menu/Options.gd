extends Control

var save_names = ["user://save1Data.txt", "user://save2Data.txt", "user://save3Data.txt"]

func _ready():
	$DeleteBox.visible = false
	$CreditsBox.visible = false
	update_delete_box()
	

func update_delete_box():
	var buttons = [$DeleteBox/VBox/Delete1, $DeleteBox/VBox/Delete2, $DeleteBox/VBox/Delete3]
	
	# create new file instance
	var data_file = File.new()
	
	# loops through save names and checks if it exists
	for name in save_names:
		var save_index = int(name[11]) - 1
		if not data_file.file_exists(name):
			# disable button if there is no save
			buttons[save_index].disabled = true

func _on_Back_pressed():
	SceneTransition.change_scene('res://main_menu//MainMenu.tscn')


func delete(name: String):
	# create new directory instance
	var dir = Directory.new()
	
	# removes file based on name
	dir.remove(name)
	$DeleteBox.visible = false
	
	# updates delete box so that the button is disabled (can't delete a file that isn't there anymore)
	update_delete_box()

# Delete save buttons
func _on_Delete1_pressed():
	delete(save_names[0])
func _on_Delete2_pressed():
	delete(save_names[1])
func _on_Delete3_pressed():
	delete(save_names[2])

# functions for delete box visibility
func _on_Delete_pressed():
	$DeleteBox.visible = true
func _on_Cancel_pressed():
	$DeleteBox.visible = false


func _on_Credits_Cancel_pressed():
	$CreditsBox.visible = false

func _on_Credits_pressed():
	$CreditsBox.visible = true
