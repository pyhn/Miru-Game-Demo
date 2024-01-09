extends CanvasLayer

# signal that tells scene switcher that lvl has changed
signal lvl_changed(lvl_name, next_lvl)
signal pruchase(item)

# adds script variable in inspector
export (String) var lvl_name = "lvl"

var time_start = 0 # time variables
var time_now = 0
var cur_time = 0

var lvl_param := { # dictionary for game data
	"name": "Player",
	"money": 10000,
	"energy": 4,
	"trust": 50,
	"love": 5,
	"mood": "neutral",
	"tod": 0,
	"date": "M/D/20XX",
	"days": 0,
	"time_played": 0,
	"inv": {"ice_cream": 0, "pudding": 0, "cold_med" : 0, "cook_ingred": 0, "noodles":0, "movie_tickets":0, "energy_drink": 0},
	"new_game": 1
	}

var save_file_name: String = "user://save" + str(Globals.save_profile) + "Data.txt"

# called when ANY level is loaded
func _ready():
	time_start = OS.get_unix_time()	 # gets start time
	
	# dont want to load from file everytime opening room, so check if it's first load from main menu
	if Globals.first_load == 0:
		load_save()
		Globals.first_load = 1
		
	if lvl_name == 'Intro':
		$Intro/EnterName.grab_focus()
	
		

# called on every frame on current level
func _process(delta):
	if lvl_name == 'Room':
		if $Room/Return.visible == false:
			time_now = OS.get_unix_time() # gets time every frame
			cur_time = time_now - time_start # time is calculated every frame
			var formated = format_time(cur_time + lvl_param.time_played) # add the time we have played to current time, then format
			$Room/Stats/DictVBox/TimePlayed.text = "Time Played: " + formated
	elif lvl_name == "Loading" || lvl_name == "Intro" || lvl_name == "Sleeping":
		pass
	
	else:
		time_now = OS.get_unix_time() # gets time every frame
		cur_time = time_now - time_start # time is calculated every frame
		var formated = format_time(cur_time + lvl_param.time_played)

func format_time(time: int):
	var sec_total = time
	var h = sec_total / 3600 # finds max amount of hours
	var m = sec_total % 3600 / 60 # finds max amoutn of minutes remaining\
	var s = sec_total % 3600 % 60 # finds max amoutn of seconds remaining
	var time_played_formated = "{0}:{1}:{2}".format({0:"%02d" % h, 1:"%02d" % m, 2:"%02d" % s})
	return time_played_formated

func load_lvl_param(new_lvl_param: Dictionary): #updates lvl_param
	lvl_param = new_lvl_param
	if lvl_name == 'Room':
		load_room()
		
	if lvl_name == 'Sleeping':
		if lvl_param.days == 7 || lvl_param.days == 14 || lvl_param.days == 21:
			$Rent.visible = true
		else:
			$Rent.visible = false
		$Days.text = 'Day ' + str(lvl_param.days)
		var timer = get_node("SleepTimer")
		timer.start()
	
	if lvl_name == 'Shop':
		check_purchase()
		$Shop/Money.text = "Money: " + str(lvl_param.money)
		


# function that updates room user interface
func load_room():
	if lvl_param.energy == 0:
		$Room/MenuVBox/Shop.disabled = true
		$Room/MenuVBox/Talk.disabled = true
		$Room/MenuVBox/Work.disabled = true
	if lvl_param.tod == 2:
		$Room/MenuVBox/Work.disabled = true
	$Room/Stats/DictVBox/Name.text = 'Name: ' + lvl_param.name
	$Room/Stats/DictVBox/Money.text = 'Money: ' + str(lvl_param.money)
	$Room/Stats/DictVBox/Energy.text = 'Energy: ' + str(lvl_param.energy)
	$Room/Stats/DictVBox/ToD.text = string_tod(lvl_param.tod)
	$Room/Stats/DictVBox/Days.text = 'Days: ' + str(lvl_param.days)
	$Room/Stats/DictVBox/Save.text = 'Save File: ' + str(Globals.save_profile)
	
	$Room/Inventory/InventoryVBox/ice_cream.text = 'Ice Cream: ' + str(lvl_param.inv.ice_cream)
	$Room/Inventory/InventoryVBox/pudding.text = 'Pudding: ' + str(lvl_param.inv.pudding)
	$Room/Inventory/InventoryVBox/cold_med.text = 'Cold Medicine: ' + str(lvl_param.inv.cold_med)
	$Room/Inventory/InventoryVBox/cook_ingred.text = 'Cooking Ingredients: ' + str(lvl_param.inv.cook_ingred)
	$Room/Inventory/InventoryVBox/noodles.text = 'Noodles: ' + str(lvl_param.inv.noodles)
	$Room/Inventory/InventoryVBox/movie_tickets.text = 'Movie Tickets: ' + str(lvl_param.inv.movie_tickets)
	$Room/Inventory/InventoryVBox/energy_drink.text = 'Energy Drinks: ' + str(lvl_param.inv.energy_drink)
	

func string_tod(value: int):
	if value == 0:
		return "Morning"
	elif value == 1:
		return "Afternoon"
	else:
		return "Night"
	

func _on_Back_pressed():
	if $Room/Return.visible == false: # if not visible when pressed
		$Room/Return.visible = true # make visible
	$Room/Blur.visible = true


func _on_Yes_pressed():
	# save to json here before returning to menu
	save_data()
	Globals.first_load = 0
	SceneTransition.change_scene('res://main_menu//MainMenu.tscn')
	
func _on_No_pressed():
	$Room/Return.visible = false
	$Room/Blur.visible = false
	
func save_data() -> void:
	# updates time played before quitting
	lvl_param.time_played += cur_time
	
	# create file instance to write to
	var save_file = File.new()
	
	# open file at path for writing
	save_file.open(save_file_name, File.WRITE)
	
	# writing to file (converting dictionary to json)
	# if file DNE, makes new file, otherwise, overwrite
	save_file.store_line(to_json(lvl_param))
	
	
	# close file
	save_file.close()

# cleans up level
func cleanup(): 
	queue_free()

# can add sound effects or other things when scene is loaded
func play_loaded():
	pass

func load_save() -> void:
	# create file instance to read from
	var data_file = File.new()
	var timer = get_node("Loading/Timer")
	# check if file exists in system
	if not data_file.file_exists(save_file_name):
		# timer for scene signal
		timer.start()
		
	else:
		lvl_param.new_game = 0
		timer.start()
		
		# open file at path for reading
		data_file.open(save_file_name, File.READ)
		# loops through file line by line
		while data_file.get_position() < data_file.get_len():
			# since we only have one dictionary, it only checks the single line
			var node_data = parse_json(data_file.get_line())
			
			# grabs data from file and loads game state
			lvl_param.name = node_data["name"]
			lvl_param.money = node_data["money"]
			lvl_param.energy = node_data["energy"]
			lvl_param.trust = node_data["trust"]
			lvl_param.love = node_data["love"]
			lvl_param.mood = node_data["mood"]
			lvl_param.tod = node_data["tod"]
			lvl_param.date = node_data["date"]
			lvl_param.days = node_data["days"] 
			lvl_param.time_played = node_data["time_played"]
			lvl_param.new_game = node_data["new_game"]
	
	# close file
	data_file.close()
			

func _on_BackToRoom_pressed():# before switching scenes, add time on current scene to time_played
	lvl_param.energy -= 1 # increased amount of time before returning to room
	
	if lvl_name == "Shop":
		lvl_param.tod += 1
	
	if lvl_name == "Work":
		lvl_param.tod == 2
	
	emit_signal("lvl_changed", lvl_name, "Room")


func _on_Shop_pressed():
	emit_signal("lvl_changed", lvl_name, "Shop")


func _on_Timer_timeout():
	# loads correct level based on if current playthrough is new or returning
	if lvl_param.new_game == 1:
		print("why here")
		emit_signal("lvl_changed", lvl_name, "Intro")
	if lvl_param.new_game == 0:
		emit_signal("lvl_changed", lvl_name, "Room")

func _on_EnterName_text_entered(new_text):
	# saves inputted name into dict
	lvl_param.name = $Intro/EnterName.text
	# value to check if returning player set to 0
	lvl_param.new_game = 0
	# change player's name in Dialogic plugin
	emit_signal("lvl_changed", lvl_name, "Room")

func _on_Sleep_pressed():
	lvl_param.days += 1
	lvl_param.tod = 0
	if lvl_param.days == 7 || lvl_param.days == 14 || lvl_param.days == 21:
			lvl_param.money -= 5000
	emit_signal("lvl_changed", lvl_name, "Sleeping")


func _on_SleepTimer_timeout():
	emit_signal("lvl_changed", lvl_name, "Room")

func _on_Work_pressed():
	pass

func check_inv():
	var keys = ["ice_cream", "pudding", "cold_med", "cook_ingred", "noodles", "movie_tickets", "energy_drink"]
	var temp = 'Room/Inventory/InventoryVBox/'
	for item in keys:
		var btn = get_node(temp + item)
		if lvl_param.inv[item] == 0:
			btn.disabled = true
			

func _on_Inv_pressed():
	check_inv()
	$Room/Inventory.visible = true
	$Room/Blur.visible = true


func _on_X_pressed():
	$Room/Inventory.visible = false
	$Room/Blur.visible = false

func item_purchased(item: int):
	var cost
	match item:
		1:
			cost = 100
			lvl_param.inv.ice_cream += 1
		2:
			cost = 200
			lvl_param.inv.pudding += 1
		3:
			cost = 1000
			lvl_param.inv.cold_med += 1
		4:
			cost = 500
			lvl_param.inv.cook_ingred += 1
		5:
			cost = 200
			lvl_param.inv.noodles += 1
		6:
			cost = 1000
			lvl_param.inv.movie_tickets += 1
		7:
			cost = 500
			lvl_param.inv.energy_drink += 1
			
	lvl_param.money -= cost
	$Shop/Money.text = "Money: " + str(lvl_param.money)
	check_purchase()
	
func check_purchase():
	if lvl_param.money < 1000:
		$Shop/ItemVBox/ColdMed.disabled = true
		$Shop/ItemVBox/MovieTickets.disabled = true
	if lvl_param.money < 750:
		$Shop/ItemVBox/CookIngred.disabled = true
	if lvl_param.money < 500:
		$Shop/ItemVBox/EnergyDrinks.disabled = true
	if lvl_param.money < 200:
		$Shop/ItemVBox/Noodles.disabled = true
		$Shop/ItemVBox/Pudding.disabled = true
	if lvl_param.money < 100:
		$Shop/ItemVBox/IceCream.disabled = true


func _on_IceCream_pressed():
	item_purchased(1)
func _on_Pudding_pressed():
	item_purchased(2)
func _on_ColdMed_pressed():
	item_purchased(3)
func _on_CookIngred_pressed():
	item_purchased(4)
func _on_Noodles_pressed():
	item_purchased(5)
func _on_MovieTickets_pressed():
	item_purchased(6)
func _on_EnergyDrinks_pressed():
	item_purchased(7)
