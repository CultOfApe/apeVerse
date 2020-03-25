extends Node

#TODO: add typing to these
onready var gameRoot 		= get_tree().get_root().get_node("game")
onready var sceneCol 		= get_tree().get_root().get_node("game").get_node("scene").get_node("col")
onready var sceneGeometry 	= get_tree().get_root().get_node("game").get_node("scene").get_node("Area")
onready var transition 		= get_tree().get_root().get_node("game").get_node("ui/transition")
onready var audio 			= get_tree().get_root().get_node("game").get_node("audio")
onready var locLabel 		= get_tree().get_root().get_node("game").get_node("ui/location")
onready var locTweenIn 		= get_tree().get_root().get_node("game").get_node("ui/location/tween_in")
onready var locTweenOut 	= get_tree().get_root().get_node("game").get_node("ui/location/tween_out")
onready var worldEnv 		= get_tree().get_root().get_node("game").get_node("Camera/env")
onready var lightDir 		= get_tree().get_root().get_node("game").get_node("pos3d/DirectionalLight")
onready var lightDummy 		= get_tree().get_root().get_node("game").get_node("pos3d")

var gameType 		: String


#TODO: these variables are confusing. Go over and add clarifying comments to each
var day 			: int
var gameday 		: int
var weekday 		: String
var timeofday 		: String
var month 		
var monthNum		: int
var firstofmonth	: int
var date 			: int
var calendarOffset  : int

var scene 				: String
var locations 			: Array
var currentLocation 	: String
var previous_location 	: String

# TODO: Eveventually, all these should probably be store in a unified cache, instead of 10+
var tempData
var sceneData 		: Dictionary
var locationData	: Dictionary
var locData			: Dictionary # locationData should cover same function
var gameData 		: Dictionary
var eventData 		: Dictionary
var charData 		: Dictionary
var gameVars 		: Dictionary
var inventoryData 	: Dictionary
var contactData 	: Dictionary
var editorData		: Dictionary
var galleryData  	: Dictionary = {
	"img01" : "res://data/graphics/img01.png",
	"img02" : "res://data/graphics/img02.png",
	"img03" : "res://data/graphics/img03.png",
	"img04" : "res://data/graphics/img04.png",
	"img05" : "res://data/graphics/img05.png",
	"img06" : "res://data/graphics/img06.png"
}

var saveData  : Dictionary = {
		"save1" : [{
			"id" : "01",
			"thumb" : "save_add",
			"data" : {}
		}]	
	}

# REFACTOR: remove _running suffix from all
var dialogue_running 	: bool
var blocking_ui 		: bool 		= false
var phone_app_running 	: bool		= false
var editor				: bool		= false
var settings			: bool		= false
var playerMoving		: bool		= false
var calendarUpdate		: bool		= false
var itemInHand 			: String 	= ""

var gallery_page 		: int 		= 1
var save_page 			: int 		= 1
var eventOverride = {}

var files 				: Array
var removedActors		: Array
	
var playerScript : Script = preload("res://data/scripts/player.gd")
var playerPos

var capture

func _ready():
	set_process(true)
	
	dialogue_running = false
	
	inventoryData 	= load_json("res://data/global/inventory_data.json")
	eventData 		= load_json("res://data/events/gameEvents.json")
	gameData 		= load_json("res://data/global/game_data.json")
	charData 		= load_json("res://data/global/character_data.json")
	locations 		= load_json("res://data/global/location_data.json")
		
	for loc in locations:
		locData[loc] = load_json("res://data/locations/location_" + loc + ".json")
		
	contactData 	= load_json("res://data/global/contact_data.json")
	
	for location in locations:
		sceneData[location] = load_json("res://data/locations/location_" + location + ".json")
	
	# To facilitate coding, this game assumes a year of 360 days and 30 day months
	# weekday and month is calculated based on how many days of 360
	gameday = 1	# actual day in game
	day = 156	# day from the beginning of the year
	weekday = gameData["weekday"][(day % ((day / 7) * 7) - 1)] # assumes first day of the year is a monday, which is fine for now
	timeofday = "morning"
	monthNum = day / 30 +1
	month = gameData["month"][monthNum -1]
	
	firstofmonth = (monthNum-1) * 30 + 1
	calendarOffset = firstofmonth % ((firstofmonth / 7) * 7) - 1
	date = day % (30 * monthNum) #gives day of month
	
	transition.hide()
		
	audio.playing = true

func _process(delta):
	if Input.is_action_pressed("ui_reload"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("ui_quit"):
		get_tree().quit()
		
func change_cursor(id):
	var cursor = load("res://data/graphics/cursor_" + id + ".png")
	Input.set_custom_mouse_cursor(cursor)

# Hack solution that doesn´t work very well, but low priority for now
func grab_screen():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	capture = get_viewport().get_texture().get_data()
	
	capture.flip_y()
	capture.convert(5)

func list_files_in_directory(path):
	
	files.clear()
	
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and !file.ends_with("import"):
			files.append(file)
			
	dir.list_dir_end()

	return files
	
func load_json(json):
		var file = File.new()
		file.open(json, File.READ)
		tempData = parse_json(file.get_as_text())
		return tempData
		tempData = null
		file.close()

func goto_scene(scene):
	get_tree().change_scene("res://"+scene)

func load_scene(sceneLocation): #change this first, see if any conflicts
		
	var actor
	var object
	var pos
	var rot
	
	previous_location = currentLocation
	currentLocation = sceneLocation
	
	#ugly, hardcoded, placeholder daytime transition. Works fine for now.
	if sceneData[scene]["environment"] == "exterior":
		if timeofday == "morning":
			environmentLight(30, Color(0.8, 1, 0.8, 0.5), 0.7, 0.6, Vector3(0, 0, 0))
		if timeofday == "noon":
			environmentLight(50, Color(1, 1, 1, 1), 1.5, 1, Vector3(50, 0, 0))
		if timeofday == "evening":
			environmentLight(15, Color(0.2, 0.2, 1, 1), 0.2, 0.2, Vector3(100, 0, 0))
		if timeofday == "night":
			environmentLight(0, Color(0.2, 0.2, 1, 1), 0.01, 0.05, Vector3(120, 0, 0))
			
	elif sceneData[scene]["environment"] == "interior":
		environmentLight(30, Color(0.8, 1, 0.8, 0.5), 0.7, 0.6, Vector3(0, 0, 0))
	
	if sceneData[sceneLocation].has(weekday):
		locationData = sceneData[sceneLocation][weekday][timeofday]
	else:
		locationData = sceneData[sceneLocation]["default"][timeofday]

	#if today has event override
	if eventData["date"].has(str(gameday)) and eventData["date"][str(gameday)].has(timeofday):
		if eventData["date"][str(gameday)][timeofday]["type"] == "oneoff":
			eventOverride = load_json("res://data/events/" + eventData["date"][str(gameday)][timeofday]["event"] + ".json")

	else:
		pass
	
	gameRoot.get_node("player").queue_free()
	gameRoot.get_node("player").set_name("DELETED")

	for child in gameRoot.get_node("scene").get_children():
		#check that we delete everything but the collision node
		if child.name != "col":
			child.set_name("DELETED")
			child.queue_free()
			
	for child in gameRoot.get_node("objects").get_children():
		child.set_name("DELETED")
		child.queue_free()
			
	var scene = load("res://data/locations/" + sceneLocation + ".tscn")
	scene = scene.instance()
	gameRoot.get_node("scene").add_child(scene)
	
#	Determine if we´re doing a 3d adventure game or Visual Novel-style game, by checking for type of first node in scene (Area/Area2D)
#	This is just the first preparation. 
#	Still TODO: code currently assumes 3d meshes when placing NPCs and Objects (Using a Vector3) - need to allow for Vector2 position
	var player = load("res://data/asset scenes/player.tscn")
	player = player.instance()
	
	if scene.is_class("Area"):
		gameType = "3D"
		player.set_translation(Vector3(0,0.6,0))
		player.set_rotation(Vector3(-0,0,-0))
	elif scene.is_class("Area2d"):
		gameType = "2D"
		player.set_translation(Vector2(0,0))
		player.set_rotation(Vector2(0,0))
	else:
		gameType = "Visual Novel"
		
	player.set_name("player")
	player.set_script(playerScript)
	gameRoot.get_node("scene").connect("input_event", player,"_on_scene_input_event")
	gameRoot.add_child(player)

	for child in gameRoot.get_node("npcs").get_children():
		child.set_name("DELETED")
		child.queue_free()
	
	if eventOverride and eventOverride.has("remove"):
		if eventOverride["remove"].has("actor"): #and eventOverride["remove"]["actor"][0] != "all"    <-gives string/array error...
			for i in eventOverride["remove"]["actor"]:
				removedActors.push_back(i)
		elif eventOverride["remove"]["actor"] == "all":
			removedActors.push_back("all")
					
	if locationData.has("actors"):
		for name in locationData["actors"].keys():
			pos = locationData["actors"][name]["pos"]
			rot = locationData["actors"][name]["rot"]

			if locationData["actors"][name]["dialogue"] != "default":
				global.charData[name]["dialogue"]["default"]["path"] = locationData["actors"][name]["dialogue"]
			
			_add_to_scene("actor", name, "npcs", rot, pos)
			
	#TODO: use the template above to complete this conditional
	if eventOverride != null and eventOverride.has("add") and eventOverride["calendar"]["location"] == currentLocation:
		if  eventOverride["add"].has("actor"):
			for i in eventOverride["add"]["actor"].size():	
				if !removedActors.has(i) or !removedActors.has("all"):
					pos = eventOverride["add"]["actor"][i]["pos"]
					rot = eventOverride["add"]["actor"][i]["rot"]
#					charData[name]["dialogue"] = eventOverride["add"]["actor"][i]["dialogue"]
					actor = load("res://data/npcs/" + eventOverride["add"]["actor"][i]["id"] + ".tscn")
					print("Actor override: " + eventOverride["add"]["actor"][i]["id"])
					_add_to_scene("actor", eventOverride["add"]["actor"][i]["id"], "npcs", rot, pos)
		
	if locationData.has("objects"):
		for name in locationData["object"].size():
			pos = locationData["objects"][name]["pos"]
			rot = locationData["actors"][name]["rot"]
			
			_add_to_scene("object", name, "objects", rot, pos)
				
	#TODO: use the template above to complete this conditional		
	if eventOverride != null and eventOverride.has("add"):
		if eventOverride["add"].has("object"):
			for name in locationData["object"].size():
				pos = eventOverride["add"]["object"][name]["pos"]
				rot = eventOverride["add"]["object"][name]["rot"]
				
				_add_to_scene("object", name, "objects", rot, pos)

	#set eventOverride back to null, as it´s only needed and updated when calling load_scene()
	eventOverride = {}
	
	sceneGeometry 	= get_tree().get_root().get_node("game").get_node("scene").get_node("Area")
#	for i in sceneGeometry.get_children():
#		print(i.get_name())
#
#	for i in sceneGeometry.get_node("Area").get_children():
#		print(i.get_name())
	sceneGeometry.connect("on_click", self, "load_scene")
		
#	TODO: how to handle scene specific cameras?

	if previous_location != currentLocation:
		pass

func _add_to_scene(type, id, group, rot, pos):
	var node = load("res://data/" + group + "/" + id + ".tscn")			
	node = node.instance()
	node.set_translation(Vector3(pos.x, pos.y, pos.z))
	node.set_rotation(Vector3(rot.x,rot.y, rot.z))
	node.set_name(id)
	gameRoot.get_node(group).add_child(node)

func environmentLight(latitude, color, ambience, energy, rotation):
	worldEnv.environment.background_sky.sun_latitude = latitude
	worldEnv.environment.background_sky.sun_color = color
	worldEnv.environment.ambient_light_energy = ambience
	lightDir.light_energy = energy
	lightDummy.rotation_degrees = rotation

func event_notifier():
	pass
	
func setup_grid(type, rows, cols): #type can be text, image or custom (load prefab node)
	if type == "text":
		for i in rows:
			for i in cols:
				pass
	elif type == "image":
		for i in rows:
			for i in cols:
				pass
	else:
		for i in rows:
			for i in cols:
				pass
	
func _save_game(id):
#	saveData["player"]["position"] = gameRoot.get_node("player").get_positon()
#	saveData["player"]["rotation"] = gameRoot.get_node("player").get_rotation()
	saveData["currentLocation"] = currentLocation
	saveData["eventData"] = eventData
	saveData["gameVars"] = gameVars
	saveData["CharData"] = charData
	
	var file = File.new()
	file.open("res://data/saves/" + id + ".save", File.WRITE)
	file.store_line(to_json(saveData))
	file.close()
	
func _load_game(id):
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
