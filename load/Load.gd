extends Node

# starts with no next level
var next_lvl = null

# default room when Load.tscn is called for the first time
onready var cur_lvl = $Loading

# important that this variable is always read for scene change animations
onready var anim = $AnimationPlayer


func _ready():
	#connects current level scene to level change signal, and then calling function to handle the level change
	cur_lvl.connect('lvl_changed', self, 'handle_lvl_changed')

func handle_lvl_changed(cur_lvl_name: String, next_lvl_name: String):
	# load() holds a scene file (packed scene), so we need to isntance it
	next_lvl = load("res://levels/" + next_lvl_name + ".tscn").instance() 
	
	cur_lvl.lvl_param.time_played += cur_lvl.cur_time
	# transfers data between levels
	transfer_data(cur_lvl, next_lvl)
	
	# next level is drawn under current level until its ready
	next_lvl.layer = -1
	
	# add to scene tree and play animation
	add_child(next_lvl)
	anim.play("fade_in")
	next_lvl.connect("lvl_changed", self, "handle_lvl_changed")


func transfer_data(old_scene, new_scene):
	# loads lvl parameters from old scene into the new scene
	new_scene.load_lvl_param(old_scene.lvl_param)

func _on_AnimationPlayer_animation_finished(anim_name: String):
	# allows us to make do something based on animations
	match anim_name:
		"fade_in":
			cur_lvl.cleanup() # level scene function that cleans up current level
			cur_lvl = next_lvl # makes next level the current level
			cur_lvl.layer = 1 # restores it to regular layer
			next_lvl = null
			anim.play("fade_out")
			
		"fade_out":
			cur_lvl.play_loaded() # level scene function that runs when fade out is finished
