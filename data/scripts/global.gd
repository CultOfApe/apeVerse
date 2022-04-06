extends Node

# TODO: Eveventually, all these should probably be store in a unified cache, instead of 10+
var sceneData 		: Dictionary
var locationData	: Dictionary
var gameData 		: Dictionary	= load_json("res://data/global/game_data.json")
var eventData 		: Dictionary	= load_json("res://data/events/gameEvents.json")
var charData 		: Dictionary	= load_json("res://data/global/character_data.json")
var inventoryData 	: Dictionary	= load_json("res://data/global/inventory_data.json")
var contactData 	: Dictionary	= load_json("res://data/global/contact_data.json")
var editorData		: Dictionary
var saveData  		: Dictionary 
var gameVars 		: Dictionary
var completion_points := 0

#TODO: add typing to these
onready var game 		= $"/root/game/"
onready var floor_collision = $"/root/game/scene/col"
onready var sceneGeometry 	= $"/root/game/scene/Area"
onready var transition 		= $"/root/game/ui/transition"
onready var audio 			= $"/root/game/audio"
onready var locLabel 		= $"/root/game/ui/location"
onready var locTweenIn 		= $"/root/game/ui/location/tween_in"
onready var locTweenOut 	= $"/root/game/ui/location/tween_out"
onready var environment 	= $"/root/game/Camera/environment"
onready var light 			= $"/root/game/light/DirectionalLight"
onready var light_container = $"/root/game/light"

onready var player 			= $"/root/game/player"
onready var camera 			= $"/root/game/Camera"
onready var speech_balloon	= load("res://data/UI/nodes/speech_balloon.tscn")

var game_type 		: String	# 3d or 2d

# day number from start of game
var	gameday = 1					# actual day in game
# day = 156	- day from the beginning of the year
var	day = 156					# day from the beginning of the year
# timeofday = "morning"
var	timeofday = "morning"
# monthNum = day / 30 +1
var	monthNum = day / 30 +1
# monday through sunday - gameData["weekday"][(day % ((day / 7) * 7) - 1)]
var	weekday = gameData["weekday"][(day % ((day / 7) * 7) - 1)] # assumes first day of the year is a monday
# month = gameData["month"][monthNum -1]
var	month = gameData["month"][monthNum -1]
# firstofmonth = (monthNum-1) * 30 + 1
var firstofmonth = (monthNum-1) * 30 + 1
# calendarOffset = firstofmonth % ((firstofmonth / 7) * 7) - 1
var	calendarOffset = firstofmonth % ((firstofmonth / 7) * 7) - 1
# date = day % (30 * monthNum) #gives day of month
var	date = day % (30 * monthNum) #gives day of month

var scene 				: String
var locations 			: Array		= load_json("res://data/global/location_data.json")
var currentLocation 	: String
var previous_location 	: String

# REFACTOR: remove _running suffix from all
var dialogue_running 	: bool		= false
var blocking_ui 		: bool 		= false
var phone_app_running 	: bool		= false
var editor				: bool		= false
var settings			: bool		= false
var playerMoving		: bool		= false
var update_calendar		: bool		= false
var lookingAt 			: bool 		= false
var itemInHand 			: String 	= ""

var hover				: Dictionary	= {
	"id"	: null,
	"type"	: null,
	"position" : null
}

var UI_lvl 				: int	= 0
var editor_lvl 			: int	= 0
var dialogue_waiting 	: bool = false

var gallery_page 		: int 		= 1
var eventOverride = {}
	
var playerScript : Script = preload("res://data/scripts/player.gd")
var playerPos
var playerLocRotOverride = null

var active_character : String

var capture = null

func _ready():
	setup_game()

func _process(delta):
	if Input.is_action_pressed("ui_reload"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("ui_quit"):
		get_tree().quit()
		
func setup_game():		
	for location in locations:
		sceneData[location] = load_json("res://data/locations/" + location + ".json")
	
	transition.hide()
	audio.playing = true
	
func connect_stuff():
	for object in $"/root/game/objects".get_children():
		object.connect("look_at", self, "look_at")
		object.connect("highlight", self, "highlight")
		
	for object in $"/root/game/npcs".get_children():
		object.connect("look_at", self, "look_at")
		object.connect("dialogue", $"/root/game/dialogue", "talk_to")
		object.connect("highlight", self, "highlight")
		
func look_at(text):
	global.balloon(text, $"/root/game/player", "player")

# TODO: This can go to NPC or Object nodes
func highlight(text):
	$"/root/game/ui/description".set_text(text)
	
func change_cursor(id):
	var cursor = load("res://data/ui/graphics/cursor_" + id + ".png")
	Input.set_custom_mouse_cursor(cursor)

func goto_scene(scene):
	get_tree().change_scene("res://"+scene)

func load_scene(location): #change this first, see if any conflicts
	
#	print("----------------------------")
#	print("DEBUG global.gd.gd")
#	print("----------------------------")
#	print(" ")
#	print(" loading: " + location)
#	print(" ")
	
	var actor
	var actors_removed		: Array
	var object
	var pos
	var rot
	
	previous_location = currentLocation
	currentLocation = location
	
	# ugly, hardcoded, placeholder daytime transition. Works fine for now.
	# func set_environment(latitude, color, ambience, energy, rotation)
	print(sceneData[location]["environment"])
	if sceneData[location]["environment"] == "exterior":
		if timeofday == "morning":
			set_environment(30, Color(0.8, 1, 0.8, 0.5), 0.7, 0.6, Vector3(0, 0, 0))
		if timeofday == "noon":
			set_environment(50, Color(1, 1, 1, 1), 1.5, 1, Vector3(50, 0, 0))
		if timeofday == "evening":
			set_environment(15, Color(0.2, 0.2, 1, 1), 0.2, 0.2, Vector3(100, 0, 0))
		if timeofday == "night":
			set_environment(0, Color(0.2, 0.2, 1, 1), 0.01, 0.05, Vector3(120, 0, 0))
			
	elif sceneData[location]["environment"] == "interior":
		set_environment(30, Color(0.8, 1, 0.8, 0.5), 0.7, 0.6, Vector3(0, 0, 0))
	
	if sceneData[location].has(weekday):
		locationData = sceneData[location][weekday][timeofday]
	else:
		locationData = sceneData[location]["default"][timeofday]

	#if today has event override
	if eventData["date"].has(str(gameday)) and eventData["date"][str(gameday)].has(timeofday):
		if eventData["date"][str(gameday)][timeofday]["type"] == "oneoff":
			eventOverride = load_json(
				"res://data/events/" + eventData["date"][str(gameday)][timeofday]["event"] + ".json")
	
	game.get_node("player").queue_free()
	game.get_node("player").set_name("DELETED")

	for child in game.get_node("scene").get_children():
		#check that we delete everything but the collision node
		if child.name != "col":
			child.set_name("DELETED")
			child.queue_free()
			
	for child in game.get_node("objects").get_children():
		child.set_name("DELETED")
		child.queue_free()
			
	var scene = load("res://data/locations/" + location + ".tscn")
	scene = scene.instance()
	game.get_node("scene").add_child(scene)
	
#	Determine if we´re doing a 3d adventure game or Visual Novel-style game, by checking for type of first node in scene (Area/Area2D)
#	This is just the first preparation. 
#	Still TODO: code currently assumes 3d meshes when placing NPCs and Objects (Using a Vector3) - need to allow for Vector2 position
	var player = load("res://data/asset scenes/player.tscn")
	player = player.instance()
	
	if scene.is_class("Area"):
		game_type = "3D"
		player.set_translation(Vector3(0,0.6,0))
		player.set_rotation(Vector3(-0,0,-0))
		if playerLocRotOverride != null:
			player.set_translation(playerLocRotOverride[0])
			player.set_rotation(playerLocRotOverride[1])
			playerLocRotOverride = null
	elif scene.is_class("Area2d"):
		game_type = "2D"
		player.set_translation(Vector2(0,0))
		player.set_rotation(Vector2(0,0))
	else:
		game_type = "Visual Novel"
		
	player.set_name("player")
	player.set_script(playerScript)
	game.get_node("scene").connect("input_event", player,"_on_scene_input_event")
	game.add_child(player)

	for child in game.get_node("npcs").get_children():
		child.set_name("DELETED")
		child.queue_free()
	
	if eventOverride and eventOverride.has("remove"):
		if eventOverride["remove"].has("actor"): #and eventOverride["remove"]["actor"][0] != "all"    <-gives string/array error...
			for i in eventOverride["remove"]["actor"]:
				actors_removed.push_back(i)
		elif eventOverride["remove"]["actor"] == "all":
			actors_removed.push_back("all")
					
	if locationData.has("actors"):
		for name in locationData["actors"].keys():
			pos = locationData["actors"][name]["pos"]
			rot = locationData["actors"][name]["rot"]

			if locationData["actors"][name]["dialogue"] != "default":
				global.charData[name]["dialogue"]["default"]["path"] = locationData["actors"][name]["dialogue"]
			
			add_to_scene("actor", name, "npcs", rot, pos)
			
	if locationData.has("objects"):
		for name in locationData["objects"].keys():
			pos = locationData["objects"][name]["pos"]
			rot = locationData["objects"][name]["rot"]

			add_to_scene("object", name, "objects", rot, pos)
			
	connect_stuff()
			
	if eventOverride != null and eventOverride.has("add") and eventOverride["calendar"]["location"] == currentLocation:
		if  eventOverride["add"].has("actor"):
			for i in eventOverride["add"]["actor"].size():	
				if !actors_removed.has(i) or !actors_removed.has("all"):
					pos = eventOverride["add"]["actor"][i]["pos"]
					rot = eventOverride["add"]["actor"][i]["rot"]
					actor = load("res://data/npcs/" + eventOverride["add"]["actor"][i]["id"] + ".tscn")
					print("Actor override: " + eventOverride["add"]["actor"][i]["id"])
					add_to_scene("actor", eventOverride["add"]["actor"][i]["id"], "npcs", rot, pos)
			
	if eventOverride != null and eventOverride.has("add"):
		if eventOverride["add"].has("object"):
			for name in locationData["object"].size():
				pos = eventOverride["add"]["object"][name]["pos"]
				rot = eventOverride["add"]["object"][name]["rot"]
				
				add_to_scene("object", name, "objects", rot, pos)

	#set eventOverride back to null, as it´s only needed and updated when calling load_scene()
	eventOverride = {}
	
	sceneGeometry 	= $"/root/game/scene/Area"
	sceneGeometry.connect("on_click", self, "load_scene")
		
#	TODO: scene specific cameras
	if previous_location != currentLocation:
		pass
		
	print("DEBUG end")
	print("----------------------------")
	print(" ")

func add_to_scene(type, id, group, rot, pos):
	var node = load("res://data/" + group + "/" + id + ".tscn")			
	node = node.instance()
	node.set_translation(Vector3(pos.x, pos.y, pos.z))
	node.set_rotation(Vector3(rot.x,rot.y, rot.z))
	node.set_name(id)
	game.get_node(group).add_child(node)
	
func remove_from_scene(type, id):
	var node = game.get_node(type).get_node(id)
	node.set_name("DELETED")
	node.queue_free()	

func set_environment(latitude, color, ambience, energy, rotation):
	environment.environment.background_sky.sun_latitude = latitude
	environment.environment.background_sky.sun_color = color
	environment.environment.ambient_light_energy = ambience
	light.light_energy = energy
	light_container.rotation_degrees = rotation
	
func load_game(id):
	var file = File.new()
	file.open("res://data/saves/" + id + ".save", File.READ)
	saveData = parse_json(file.get_as_text())
	file.close()
	
	currentLocation = saveData[id]["currentLocation"]
	eventData = saveData[id]["eventData"]
	saveData["eventData"] = eventData
	saveData["gameData"] = gameData
	saveData["charData"] = charData
	
	load_scene(currentLocation)
	
		
func update_points(points):
	completion_points += points
	$"/root/game/ui/points".text = String(completion_points)
	
func proximity(origin, target, distance):
	if origin.distance_to(target) > distance:
		return false
	else:
		return true

func _save_game(id, page):
	saveData["currentLocation"] = currentLocation
	saveData["eventData"] = eventData
	saveData["gameVars"] = gameVars
	saveData["CharData"] = charData
	
	var file = File.new()
	file.open("user://data/saves/" + id + ".save", File.WRITE)
	file.store_line(to_json(saveData))
	file.close()

func event_notifier():
	pass
	
func setup_grid(type, rows, cols): #type can be text, image or custom (load prefab node)
	if type == "text":
		for row in rows:
			for cols in cols:
				pass
	elif type == "image":
		for rows in rows:
			for cols in cols:
				pass
	else:
		for rows in rows:
			for cols in cols:
				pass

func save_file(path, name, data):
	var file = File.new()
	file.open(path + name, File.WRITE)
	file.store_line(to_json(data))
	file.close()

func copy_file(path_from, path_to, name):	
	var dir = Directory.new()
	dir.copy(path_from + name, path_to + name)
	
# Hack solution that doesn´t work very well, but low priority for now
func grab_screen():
	capture = null
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	capture = get_viewport().get_texture().get_data()
	
	capture.flip_y()
	capture.convert(5)

func list_files_in_directory(path):
	var files : Array
	files.clear()
	
	var directory = Directory.new()
	directory.open(path)
	directory.list_dir_begin()

	while true:
		var file = directory.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and !file.ends_with("import"):
			files.append(file)
			
	directory.list_dir_end()

	return files
	
func load_json(json):
		var file = File.new()
		file.open(json, File.READ)
		return parse_json(file.get_as_text())
		file.close()
		
func load_user_image(id):
	var image = Image.new()
	var error = image.load("user://" + id + ".png")
	if error != OK:
			print("error: unable to load user image!")
	var texture = ImageTexture.new()
	return texture.create_from_image(image, 0)

func dissolve():
	$"/root/game/player/tweens/tween_out".interpolate_property($"/root/game/player/ui_anchor", "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$"/root/game/player/tweens/tween_out".start()
	print("global dissolve")
	active_character = ""
	
func wait_and_execute(seconds, function, target):
	#create and run timer only once, then run function dissolve()
	create_timer(target, seconds, true, function)
#	yield(self,"timer_end")

func create_timer(object_target, float_wait_time, bool_is_oneshot, string_function):
	var timer := Timer.new()
	timer.set_one_shot(bool_is_oneshot)
	timer.set_timer_process_mode(0)
	timer.set_wait_time(float_wait_time)
	timer.connect("timeout", object_target, string_function)
	self.add_child(timer)
	timer.start()
	
func balloon(text, target, type):
	var balloon
	var tween_in 	: Tween
	var tween_out	: Tween
	var node = speech_balloon.instance()
	
	node.set_name("speech_balloon")
	node.set_text("new way")
	node.add_color_override("font_color", Color(0,0,0,1))
	node.set_position(Vector2(-50, -60))
	
	if type == "player":
		balloon = $"/root/game/ui/bubble"
		tween_in = target.get_node("tweens").get_node("tween_in")
		tween_out = target.get_node("tweens").get_node("tween_out")
		target.get_node("ui_anchor").add_child(node) 
	elif type == "npc":
		balloon = $"/root/game/ui/bubble"
		tween_in = target.get_node("tweens").get_node("tween_in")
		tween_out = target.get_node("tweens").get_node("tween_out")
		target.get_node("ui_anchor").add_child(node) 

	if text != "": # and isLookingAt == false:
		if global.game_type == "3D":
			node.show()
			tween_in.interpolate_property(
				node, 
				"modulate", 
				Color(1,1,1,0), 
				Color(1,1,1,1), 
				1, 
				Tween.TRANS_LINEAR, 
				Tween.EASE_IN_OUT)
				
			tween_in.start()
			node.add_color_override("font_color", Color(0,0,0,1))
			node.set_text(text)

		lookingAt = true
