extends CanvasLayer


func change_scene(target: String) -> void:
	# play fade in animation on entering scene
	$AnimationPlayer.play("dissolve")
	
	# waits for animation to finish
	yield($AnimationPlayer, 'animation_finished')
	
	# play fade in reveresed
	$AnimationPlayer.play_backwards("dissolve")
	
	# right after animation starts, switch scenes 
	get_tree().change_scene(target)
	
