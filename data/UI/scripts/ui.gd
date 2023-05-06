class_name UI

extends Control

onready var blur_shader = $"shaders/blur"

var hover_node = null

var blockingUI 		: bool = false
var dialogueRunning : bool = false
var noMoveOnClick 	: bool = false
var itemInHand 		: String = ""

#These shouldn´t be hardcoded. Instead called from json via global.gd
var day 		: int = 2
var time 		: int = 0
var month 		: int = 6
var dayOfMonth 	: int = 1

#onready var hover_tween 		: Tween = $"/root/game/effects/tween"
#onready var toggle_tween 		: Tween = $"/root/game/effects/tween"
#onready var blur_tween			: Tween = $"tweens/blur"
#onready var fade_in 			: Tween = $"/root/game/effects/fade_in"
#onready var fade_out 			: Tween = $"/root/game/effects/fade_out"
onready var description 		: Label = $description
onready var floor_collision 	: CollisionShape= $"/root/game/scene/col"
#onready var scene_transition 	: Tween = $"/root/game/effects/scene_transition"

var phoneOpen 		: bool = false
var schoolbagOpen 	: bool = false
var mapOpen 		: bool = false
var calendarOpen 	: bool = false

#Below are Vector2d, I guess
onready var phoneHidePos 		: Vector2
onready var phoneShowPos 		: Vector2
onready var schoolbagHidePos 	: Vector2 = $"schoolbag_ui".position
onready var schoolbagShowPos 	: Vector2
onready var mapHidePos 			: Vector2
onready var mapShowPos 			: Vector2
onready var calendarHidePos 	: Vector2
onready var calendarShowPos 	: Vector2

onready var uiIconsShowPos 		: Vector2 = $map.position
onready var uiIconsHidePos 		: Vector2 = uiIconsShowPos + Vector2(0, 200)

var trans_capture : Image
var trans_tex : Texture

var change_scene : bool
var next_scene : String

onready var gameSettingsUI = load("res://data/ui/nodes/game_settings.tscn")
onready var new_item = load("res://data/ui/nodes/new_item.tscn")

func _ready():
	schoolbagShowPos = schoolbagHidePos - Vector2(0, 1000)
	phoneHidePos = $phone_ui.position
	phoneShowPos = phoneHidePos - Vector2(0, 1310)	
	mapHidePos = $map_ui.position
	mapShowPos = mapHidePos - Vector2(0, 1000)
	calendarHidePos = $calendar_ui.position
	calendarShowPos =  calendarHidePos - Vector2(0, 1000)
	
	blur_shader.modulate = Color(1, 1, 1, 0)
	
	$new_item.connect("new_item_materialized", self, "new_item_tween")
	$map_ui.connect("location_chosen", self, "load_map_location")
	
	
func new_item_tween(id):

	var tween := get_tree().create_tween()
	id.modulate = Color(1,1,1,0)
	tween.tween_property(id, "modulate", Color(1,1,1,1), 1)
	tween.tween_interval(1)
	tween.tween_property(id, "modulate", Color(1,1,1,0), 1)
	tween.tween_callback(id, "queue_free")

func _input(event):
	if event.is_action_pressed("ui_exit") and global.UI_lvl == 0:
		if !mapOpen and !schoolbagOpen and !phoneOpen and !calendarOpen and !global.dialogue_running and !global.editor:
			toggle_game_settings()
			
	if event.is_action_pressed("ui_exit") and global.UI_lvl == 1:
		global.UI_lvl = 0
		ui_exit(null)	
		global.change_cursor("default")
			
	if event.is_action_pressed("ui_exit") and global.UI_lvl == 2:
		global.UI_lvl = 1
		global.phone_app_running = false
		for app in get_tree().get_nodes_in_group("UI_lvl_2"):
			app.hide()			

	if event.is_action_pressed("ui_exit") and global.UI_lvl == 3:
		global.UI_lvl = 2
		for app in get_tree().get_nodes_in_group("UI_lvl_3"):
			app.hide()			

#   The below is disabled for now, but will be refactored at a later time
#	if event.is_action_pressed("ui_inventory") and !mapOpen and !phoneOpen and !calendarOpen and !global.settings and !global.dialogue_running:
#		if schoolbagOpen!=true:
#			toggle_ui_overlay("schoolbag_ui", "show", schoolbagShowPos)
#		else:
#			toggle_ui_overlay("schoolbag_ui", "hide", schoolbagHidePos)
#	if event.is_action_pressed("ui_mobile") and !schoolbagOpen and !mapOpen and !calendarOpen and !global.settings and !global.dialogue_running:
#		if phoneOpen!=true:
#			toggle_ui_overlay("phone_ui", "show", phoneShowPos)
#			for app in $phone_ui/apps.get_children():
#				app.hide()			
#		else:
#			toggle_ui_overlay("phone_ui", "hide", phoneHidePos)
#	if event.is_action_pressed("ui_map") and !schoolbagOpen and !phoneOpen and !calendarOpen and !global.settings and !global.dialogue_running:
#		if mapOpen!=true:
#			toggle_ui_overlay("map_ui", "show", mapShowPos)
#		else:
#			toggle_ui_overlay("map_ui", "hide", mapHidePos)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			if event.pressed:
				if global.itemInHand != "":
					global.itemInHand = ""
					global.change_cursor("default")
	if hover_node:
		if hover_node.get_name() == "phone":	
			if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
				global.UI_lvl = 1
				toggle_ui_overlay("phone_ui", "show", phoneShowPos)
				for app in $phone_ui/apps.get_children():
					app.hide()	
		elif hover_node.get_name() == "inventory":	
			if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
				global.UI_lvl = 1
				toggle_ui_overlay("schoolbag_ui", "show", schoolbagShowPos)
		elif hover_node.get_name() == "map":	
			if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():	
				global.UI_lvl = 1			
				toggle_ui_overlay("map_ui", "show", mapShowPos)
		elif hover_node.get_name() == "calendar":	
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT:
					if event.is_pressed():
						global.playerMoving = false
						advance_time()	
			if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed():
				global.UI_lvl = 1
				toggle_ui_overlay("calendar_ui", "show", calendarShowPos)

func item_in_hand(a,b):		
	var tempTex = load(b)
	Input.set_custom_mouse_cursor(tempTex)
	ui_exit(null)
		
func exit_map():
	get_parent().mapOpen = true
	get_parent().map_location()

func ui_exit(type):
	if phoneOpen == true:	
		global.phone_app_running = false
		toggle_ui_overlay("phone_ui", "hide", phoneHidePos)
	if schoolbagOpen == true:	
		global.blocking_ui = false
		toggle_ui_overlay("schoolbag_ui", "hide", schoolbagHidePos)
	if calendarOpen == true:	
		global.blocking_ui = false
		toggle_ui_overlay("calendar_ui", "hide", calendarHidePos)
	if mapOpen == true:	
		if type != "blocking":
			global.blocking_ui = false
		toggle_ui_overlay("map_ui", "hide", mapHidePos)
#	if global.settings == true:
#		hide_game_settings()


func advance_time():
	time += 1
	if time == 4:
		time = 0
		day +=1
		global.day += 1
		global.gameday += 1
		dayOfMonth += 1
		global.update_calendar = true
		if day == 7:
			day = 0
		if dayOfMonth == 30:
			dayOfMonth = 1
			month += 1
			global.update_calendar = true
			if month == 12:
				month = 0
	
	global.month = global.gameData["month"][month]
	global.weekday = global.gameData["weekday"][(global.day % ((global.day / 7) * 7)-1)]
	global.timeofday = global.gameData["time"][time]

	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	trans_capture = get_viewport().get_texture().get_data()
	
	trans_capture.flip_y()
	trans_capture.convert(5)

	var trans_tex = ImageTexture.new()

	trans_tex.create_from_image(trans_capture)

	$transition.set_texture(trans_tex)

	$transition.show()
	
	
	$transition.modulate = Color(1,1,1,1)
	var tween := get_tree().create_tween()
	tween.tween_property($transition, "modulate", Color(1,1,1,0), 1)
	
#	keep track of day, week and month
	global.playerLocRotOverride = [$"/root/game/player".get_global_transform().origin, $"/root/game/player".rotation]
	global.load_scene(global.currentLocation)
	$"date".set_text(global.gameData.time[time] + ", " + global.weekday)		

#the below functions handle hover animations for UI icons. This could probably be handled more efficiently in one generic function, not sure how
func _on_phone_mouse_entered():
	if global.itemInHand == "":
		global.change_cursor("settings")
	ui_hover("phone", $"phone/Sprite", Vector2(1.1, 1.1), true, $"phone")

func _on_phone_mouse_exited():
	if global.itemInHand == "":
		if global.blocking_ui != true:
			global.change_cursor("default")
	ui_hover("", $"phone/Sprite", Vector2(1.0, 1.0), false, null)

func _on_schoolbag_mouse_entered():
	if global.itemInHand == "":
		global.change_cursor("settings")
	ui_hover("inventory", $"inventory/Sprite", Vector2(1.1, 1.1), true, $"inventory")

func _on_schoolbag_mouse_exited():
	if global.itemInHand == "":
		if global.blocking_ui != true:
			global.change_cursor("default")
	ui_hover("", $"inventory/Sprite", Vector2(1.0, 1.0), false, null)

func _on_map_mouse_entered():
	if global.itemInHand == "":
		global.change_cursor("settings")
	ui_hover("map", $"map/Sprite", Vector2(1.1, 1.1), true, $"map")

func _on_map_mouse_exited():
	if global.itemInHand == "":
		if global.blocking_ui != true:
			var cursor := load("res://data/graphics/cursor_default.png")
			Input.set_custom_mouse_cursor(cursor)
	ui_hover("", $"map/Sprite", Vector2(1.0, 1.0), false, null)

func _on_calendar_mouse_entered():
	if global.itemInHand == "":
		global.change_cursor("settings")
	ui_hover("calendar", $"calendar/Sprite", Vector2(1.1, 1.1), true, $"calendar")

func _on_calendar_mouse_exited():
	if global.itemInHand == "":
		if global.blocking_ui != true:
			global.change_cursor("default")
	ui_hover("", $"calendar/Sprite", Vector2(1.0, 1.0), false, null)

#play effects when hovering over UI icons
func ui_hover(name, gui_node, scale, move, node):
	description.set_text(name)
	noMoveOnClick = move
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC).set_trans(Tween.EASE_OUT)
	tween.tween_property (gui_node, "scale", scale, .2)#.set_trans(Tween.TRANS_ELASTIC) #Tween.EASE_OUT
	
	hover_node = node
	#if mouse over a UI icon, disable the scene collision shape, preventing player move
	floor_collision.disabled = move

func toggle_ui_icons(toggle):
	var startPos = $"map".position
	var positionDelta
	if toggle == "show":
		positionDelta = uiIconsShowPos - startPos
	if toggle == "hide":
		positionDelta = uiIconsHidePos - startPos
	for ui_node in get_tree().get_nodes_in_group("UI_icons"):
		ui_hide_show(ui_node, positionDelta, Tween.TRANS_ELASTIC, Tween.EASE_OUT)

func toggle_ui_overlay(id, mode, deltaPos):
	var positionDelta
	var ui_node = get_node(id)
	
	if mode == "show":
		global.change_cursor("arrow")
		global.blocking_ui = true
		global.floor_collision.disabled = true
		toggle_ui_icons("hide")
		
		blur_shader.modulate = Color(1,1,1,0)
		var tween := get_tree().create_tween()
		tween.tween_property(blur_shader, "modulate", Color(1,1,1,1), 0.5)
		
		positionDelta = ui_node.position - deltaPos
	else:
		if global.itemInHand == "":
			global.change_cursor("default")
			
		toggle_ui_icons("show")
		
		blur_shader.modulate = Color(1,1,1,1)
		var tween := get_tree().create_tween()
		tween.tween_property(blur_shader, "modulate", Color(1,1,1,0), 0.5)

		positionDelta = deltaPos - ui_node.position
		
		# This is needed to avoid character moving immediately after loading new scene
		yield(get_tree(), "idle_frame")
		global.blocking_ui = false
		floor_collision.disabled = false
		
	if id == "schoolbag_ui":
		if mode == "show":
			schoolbagOpen = true
			ui_hide_show(get_node(id), Vector2(0,-1000), Tween.TRANS_QUAD, Tween.EASE_OUT)
		else:
			schoolbagOpen = false
			ui_hide_show(get_node(id), Vector2(0,positionDelta.y), Tween.TRANS_QUAD, Tween.EASE_OUT)
			
	if id == "phone_ui":
		if mode == "show":
			phoneOpen = true
			ui_hide_show(get_node(id), Vector2(0, -positionDelta.y), Tween.TRANS_QUAD, Tween.EASE_OUT)
			
			var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			get_node(id + "/homescreen").modulate = Color(1,1,1,0)						
			tween.tween_property(
				get_node(id + "/homescreen"), 
				"modulate", 
				Color(1,1,1,1), 
				0.5)
		else:
			phoneOpen = false
			ui_hide_show(get_node(id), Vector2(0,positionDelta.y), Tween.TRANS_QUAD, Tween.EASE_OUT)
			
			var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			get_node(id + "/homescreen").modulate = Color(1,1,1,1)						
			tween.tween_property(
				get_node(id + "/homescreen"), 
				"modulate", 
				Color(1,1,1,0), 
				0.5)
			
	if id == "map_ui":
		if mode == "show":
			mapOpen = true
			$"map_ui".show()
			ui_hide_show($"map_ui", Vector2(0,-1000), Tween.TRANS_QUAD, Tween.EASE_OUT)
		else:
			mapOpen = false
			ui_hide_show($"map_ui", Vector2(0,positionDelta.y), Tween.TRANS_QUAD, Tween.EASE_OUT)
			
	if id == "calendar_ui":
		if mode == "show":
			calendarOpen = true
			#TODO: update calendar day highlight
			ui_hide_show($"calendar_ui", Vector2(0,-1000), Tween.TRANS_QUAD, Tween.EASE_OUT)
		else:
			calendarOpen = false
			ui_hide_show($"calendar_ui", Vector2(0,positionDelta.y), Tween.TRANS_QUAD, Tween.EASE_OUT)

#hide or show UI icons when calling blocking UI elements, like phone, map or schoolbag
func ui_hide_show(gui_node, move_delta, trans, easer):
	var tween = get_tree().create_tween().set_trans(trans).set_ease(easer)
	
	tween.tween_property (gui_node, "position", gui_node.position + move_delta, 0.5)
#	toggle_tween.start()
	
func toggle_game_settings():
	if !global.blocking_ui and !global.settings:
		floor_collision.disabled = true
		global.grab_screen()
		$game_settings.show()
		global.blocking_ui = true
		global.settings = true

		$game_settings.modulate = Color(1,1,1,0)
		var tween := get_tree().create_tween()
		tween.tween_property($game_settings, "modulate", Color(1,1,1,1), 0.3)
		
		global.change_cursor("arrow")
#		toggle_ui_icons("hide")

	else:
		floor_collision.disabled = false
		global.blocking_ui = false
		global.settings = false
		
		$game_settings.modulate = Color(1,1,1,1)
		var tween := get_tree().create_tween()
		tween.tween_property($game_settings, "modulate", Color(1,1,1,0), 0.3)
		
		$"game_settings".hide()
		global.change_cursor("default")
#		toggle_ui_icons("show")

#func _on_fade_out_tween_completed(object, key):
#	#hide game settings from game after faded out, since it will interfere with other UI overlays even when not visible
#	$"game_settings".hide()
	
func load_map_location(location):

	ui_exit("blocking")
	$map_ui.hide()
	

	var trans_tex := ImageTexture.new()
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	trans_capture = get_viewport().get_texture().get_data()
	trans_capture.flip_y()
	trans_capture.convert(5)
	trans_tex.create_from_image(trans_capture)
	$transition.set_texture(trans_tex)
	
	$transition.show()
	
	$transition.modulate = Color(1,1,1,1)
	var tween := get_tree().create_tween()
	tween.tween_property($transition, "modulate", Color(1,1,1,0), 0.7)

	global.load_scene(location)
	$transition.hide()
	change_scene = false
	trans_capture = null
