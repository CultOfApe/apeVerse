extends Node2D

onready var VIEWSIZE : Vector2 = get_viewport_rect().size

#some of the below cannot be cast as dictionaries, because of array and dictionary mixing in the code
onready var dialogue_window 	:= load("res://data/dialogue/nodes/dialogue_window.tscn")
onready var reply_button 	:= load("res://data/dialogue/nodes/reply.tscn")
onready var screen_blur 		:= $"../effects/blurfx"
onready var blur_fx 	:= $"../effects/tween"

var dialogue 		: Dictionary
var dialogue_box 		: Dictionary
var talk_data 		= {}
var branch 			= {}
var replies 		= {}

var dialogue_type

var avatar 	= null
var npc 			: String

var dialogue_text_size := 0
var replies_size 		:= 0
var page_index 		:= 0
var reply_container 	:= []
var reply_mouseover 	:= false
var current_reply 	:= -1

var avatar_frame 	: int
var avatar_type		: String

func _ready():
	# TODO: This is getting better but should be loaded from json, and needs further adjustable variables, like offset from bottom of screen, pos of avatar/name etc.
	dialogue_box = {
		"width": 1000, 
		"height": 60, 
		"margin": Vector2(100, 20), 
		"posx": VIEWSIZE.x / 2, 
		"posy": VIEWSIZE.y / 2}
		
	for object in get_parent().get_node("npcs").get_children():
		object.connect("dialogue", self, "talk_to")
	
		
func event_handler():
	pass

func _input(event):
	if global.dialogue_running == true and reply_mouseover == false:
		#TODO: This cycles through reply choices with W(ui_up) and S(ui_down) butno way of confirming selection yet
		if event.is_action_pressed("ui_down") and current_reply != replies_size-1:
			current_reply += 1
			for reply in reply_container:
				var node := get_node(reply)
				node.add_color_override("font_color", Color(1,1,1))
			get_node(reply_container[current_reply]).add_color_override("font_color", Color(1,0,1))
		if event.is_action_pressed("ui_up") and current_reply != 0:
			current_reply -= 1
			for reply in reply_container:
				var node := get_node(reply)
				node.add_color_override("font_color", Color(1,1,1))
			get_node(reply_container[current_reply]).add_color_override("font_color", Color(1,0,1))
		
		#TODO: not working like it should. Look over, old code.
		if event.is_action_pressed("ui_accept"):
			if current_reply != -1:
				if get_node(reply_container[current_reply]).text == "exit dialogue":
					
					blur_fx.interpolate_property(
						screen_blur, 
						"modulate", 
						Color(1, 1, 1, 1), 
						Color(1, 1, 1, 0), 
						0.5, 
						Tween.TRANS_LINEAR, 
						Tween.EASE_IN)
						
					kill_dialogue()
				else:
					pick_reply(current_reply)
			if page_index < dialogue_text_size-1:    
				page_index += 1
				start_dialogue(global.charData[npc]["dialogue"][dialogue_type]["path"], dialogue_type)
			if page_index < dialogue_text_size-1:    
				page_index += 1
				start_dialogue(global.charData[npc]["dialogue"][dialogue_type]["path"], dialogue_type)
			if page_index == dialogue_text_size-1 and replies_size == 0:
				kill_dialogue()
			
func dialogue_clicked():
	if page_index < dialogue_text_size-1:    
		page_index += 1
		start_dialogue(global.charData[npc]["dialogue"][dialogue_type]["path"], dialogue_type)
	#if there are no replies - exit dialogue
	if page_index == dialogue_text_size-1 and replies_size == 0:
		global.dialogue_running = false
		kill_dialogue()

func talk_to(id, target_pos, type):
	#TODO: only able to speak to NPCs within arbitrary distance. 
	var player_pos 	: Vector3 = get_parent().get_node("player").get_global_transform().origin
	#TODO: Ideally, if player is too far from NPC, he should move closer and then start dialogue, but this is enough for now

	if player_pos.distance_to(target_pos) < 2:
		global.blocking_ui = true
		npc = id
		dialogue_type = type
		
		blur_fx.interpolate_property(
			screen_blur, 
			"modulate", 
			Color(1, 1, 1, 0), 
			Color(1, 1, 1, 1), 
			0.5, 
			Tween.TRANS_LINEAR, 
			Tween.EASE_IN)
			
		get_parent().get_node("ui").toggle_ui_icons("hide")
		start_dialogue(global.charData[id]["dialogue"][dialogue_type]["path"], dialogue_type)
	else:
		global.blocking_ui = false
		

func pick_reply(n):
	current_reply =-1

	#if there is a variables array in json, update game variables
	if replies[n].has("variables"):
		for item in range(0, replies[n]["variables"].size()):
			var name = replies[n]["variables"][item]["name"]
			global.gameData[npc] = replies[n]["variables"][item]["value"]
			#if value is a float or an int, add to existing value
			if (typeof(replies[n]["variables"][item]["value"])) == 2:
				global.gameData[npc] += replies[n]["variables"][item]["value"]
			else:
				global.gameData[npc] = replies[n]["variables"][item]["value"]
	
	#This should probably be written from scratch with all the changes made to the event system since written		
	if replies[n].has("event"):
		
		var event_cache : Dictionary = global.load_json("res://data/events/" + replies[n]["event"][0]["id"] + ".json")
		
		var today = global.day
		var currentWeekday = global.gameData["daycount"][global.weekday]
		var event_day
		var event_weekday
		
#		print("today is: " + str(today))			156
#		print("weekday is:" + global.weekday)		tuesday
#		print("gameday is:" + str(global.gameday)) 	1
		
		#what´s the weekday of the event?
		if event_cache["weekday"] != "same":
			event_day = global.gameData["daycount"][event_cache["weekday"]] - 1
			event_weekday = global.gameData["weekday"][event_day - 1]
		else:
			event_weekday = global.weekday
			event_day = today

		var event_class := {
			event_cache["timeofday"] : {"event":event_cache["event"], 
			"type": event_cache["type"], 
			"icon": event_cache["calendar"]["icon"]}
			}
		
		global.eventData["date"][str(event_day)] = event_class
		
		# TODO: cycle through more than one actor, and delete actors marked for removal
		if global.eventData["date"][str(event_day)][event_cache["timeofday"]]["type"] == "persistent":	
			global.locData[event_cache["calendar"]["location"]]= {	
				event_cache["weekday"]: {
					event_cache["timeofday"]: {
						"actors": {
							event_cache["add"]["actor"][0]["id"]: {

								"dialogue": event_cache["add"]["actor"][0]["dialogue"],
								"branch": event_cache["add"]["actor"][0]["branch"],
								"pose": event_cache["add"]["actor"][0]["model"] + ".scn",
								"pos": {
									"x": event_cache["add"]["actor"][0]["pos"]["x"],
									"y": event_cache["add"]["actor"][0]["pos"]["y"],
									"z": event_cache["add"]["actor"][0]["pos"]["z"]},
								"rot": {
									"x": event_cache["add"]["actor"][0]["rot"]["x"],
									"y": event_cache["add"]["actor"][0]["rot"]["y"],
									"z": event_cache["add"]["actor"][0]["rot"]["z"]}
							}

						}
					}
				}
					
			}
		
#		print("----------------------------")
#		print("DEBUG dialogue.gd")
#		print("----------------------------")
#		print(" global.eventData:")
#		print(" ")
#		print(" " + String(global.eventData))
#		print(" ")
#		print(" global.eventOverride:")
#		print(" " + String(global.eventOverride))
#		print(" ")
#		print("----------------------------")
#		print("DEBUG end")
#		print("----------------------------")
#		print(" ")
			
		# TODO: check if date is already present in eventData, and alert player if so
		if global.eventData["date"][str(event_day)][event_cache["timeofday"]]["type"] == "oneoff":	
			pass
				
	# if there is a progress array in json, update game progression variables
	if replies[n].has("progress"):
		# TODO: if progress has a location - update global.sceneData override instead of charData
		for item in range(0, replies[n]["progress"].size()):
			var affected : String = replies[n]["progress"][item]["name"]
			
			# TODO: allow for dialogue change for specific locations
			if replies[n]["progress"][item]["dialogue"].ends_with("phone.json"):
				global.charData[affected]["dialogue"]["phone"]["path"] = replies[n]["progress"][item]["dialogue"]
				global.charData[affected]["dialogue"]["phone"]["branch"] = replies[n]["progress"][item]["branch"]
			else:
				global.charData[affected]["dialogue"]["default"]["path"] = replies[n]["progress"][item]["dialogue"]
				global.charData[affected]["dialogue"]["default"]["branch"] = replies[n]["progress"][item]["branch"]
				
	if replies[n].has("points"):
		global.update_points((replies[n]["points"]))
			
	# TODO: a reply can trigger a change of location(and time)
	if replies[n].has("goto"):	
		pass
							
	#if "exit" is "false" take value from "next" and start next dialogue
	if replies[n]["exit"] != "true":
		if replies[n]["next"].ends_with(".json"):

			# TODO: start_dialogue("res://data/dialogue/" + charData[npc]["dialogue"]) + charData[npc]["relationship"] + (".json")
			start_dialogue(global.charData[npc]["dialogue"][dialogue_type]["path"], dialogue_type)
		else:					
			global.charData[npc]["dialogue"][dialogue_type]["branch"] = replies[n]["next"]
			page_index = 0
			start_dialogue(global.charData[npc]["dialogue"][dialogue_type]["path"], dialogue_type)
		
	
	#if "exit" is "true", kill dialogue
	else:
		page_index = 0
		
		if replies[n]["next"].ends_with(".json"):
			global.charData[npc]["dialogue"][dialogue_type]["path"] = replies[n]["next"]
		else:
			global.charData[npc]["dialogue"][dialogue_type]["branch"] = replies[n]["next"]
			
		blur_fx.interpolate_property(
			screen_blur, 
			"modulate", 
			Color(1, 1, 1, 1), 
			Color(1, 1, 1, 0), 
			0.5, 
			Tween.TRANS_LINEAR, 
			Tween.EASE_IN)
			
		global.dialogue_running = false
		kill_dialogue()
		global.blocking_ui = false
		global.sceneCol.disabled = false
		get_parent().get_node("ui").toggle_ui_icons("show")
		
		if replies[n].has("bubble"):
			global.balloon(replies[n]["bubble"], global.gameRoot.get_node("player"), "player")
		
		global.change_cursor("default")
	
func _reply_mouseover(mouseover, reply):
	if mouseover == true:
		reply_mouseover = true
		current_reply = reply
	elif mouseover == false:
		reply_mouseover = false
		current_reply = -1

func start_dialogue(json, type):

	global.change_cursor("arrow")
	
#	TODO: when calling a dialogue, call start_dialogue("ellie_date_0" + str(global.chardata["relationship"]) + ".json")
	global.dialogue_running = true
	talk_data = global.load_json(json)
	global.save_file("res://data/debug/", "debug.json", json)
	
	branch = talk_data["dialogue"][global.charData[npc]["dialogue"][type]["branch"]]
	replies = branch["replies"]

	# check how big speech array is
	dialogue_text_size = branch["speech"].size()
	
	# if branch has replies, check how many. If no responses, replies_size is 0
	if replies:
		replies_size = replies.size()
	else:
		reply_mouseover = false
		replies_size = 0
	
	# TODO: This condition should decide if to open dialogue in window, or display dialogue over character heads. Low priority..
	if branch.has("window"):
		pass
		
	# TODO: This condition currently only handles exact values, needs to evaluate if value is above another value too (ex money)
	# 0 is variable to check for
	# 1 is value of variable, and if that variable corresponds to gameVars, set 2 as current dialogue
	# 2 is target conversation (dialogue or branch)
	#thebelow block of code checks if a condition in gameVars is met, and changes dialogue accordingly if it is
	if branch.has("condition"):
		for item in branch["condition"]:
			if global.gameVars.has(branch["condition"][item][0]):
				if global.gameVars[branch["condition"][item][0]] == branch["condition"][item][1]:
					if branch["condition"][item][2].ends_with("json"):
						global.charData[talk_data["name"]]["dialogue"][dialogue_type]["path"] = branch["condition"][item][2]
					else:
						global.charData[talk_data["name"]]["dialogue"][dialogue_type]["branch"] = branch["condition"][item][2]
	
	setup_dialogue_window()
	setup_avatar()
	
	#set text and reply in dialogue panel
	$"ui_dialogue/dialogue/name".set_text(npc)
	$"ui_dialogue/dialogue".set_text(branch["speech"][page_index])
	
#	if page_index == dialogue_text_size-1 and replies_size > 0:
#		for n in range(0,replies_size):
#			reply_container.push_back("ui_dialogue/reply" + str(n+1))
#			get_node("ui_dialogue/reply" + str(n+1)).set_text(replies[n]["reply"])
		
func setup_dialogue_window():
		
	global.dialogue_waiting = true
	var reply_offset 	: int 	= 0
	var labels 			: Array = ["panel","dialogue"]
	
	#add one element "reply" per number of replies in talk_data
	for n in range(replies_size):
		labels.push_back("reply" + str(n+1))
	
	create_labels(labels)
	
	# TODO: The below could be made even more dynamic. Has some arbitrary values that don´t really work if we want diferent sized windows
#	$"ui_dialogue/panel".set_size(Vector2(dialogue_box.width, dialogue_box.height + replies_size*30))
	$"ui_dialogue/panel".set_size(Vector2(dialogue_box.width, dialogue_box.height + 240))
	$"ui_dialogue/panel".set_position(Vector2(VIEWSIZE.x /2 - dialogue_box.width / 2, VIEWSIZE.y / 2 - dialogue_box.height / 2 + 200))
	$"ui_dialogue/panel".modulate.a = 0.5
	
	$"ui_dialogue/dialogue".set_size(Vector2(dialogue_box.width, dialogue_box.height + replies_size * 30))
	$"ui_dialogue/dialogue".set_position(Vector2(VIEWSIZE.x / 2 - dialogue_box.width / 2 + dialogue_box.margin.x, 
												 VIEWSIZE.y / 2 - dialogue_box.height / 2 + dialogue_box.margin.y + 200))
	
	if page_index == dialogue_text_size-1 and replies_size > 0:
		for n in range(replies_size):
			get_node("ui_dialogue/reply" + str(n+1)).set_size(Vector2(400, 50))
			get_node("ui_dialogue/reply" + str(n+1)).set_position(Vector2(VIEWSIZE.x /2 - dialogue_box.width / 2 + dialogue_box.margin.x, 
																		  VIEWSIZE.y / 2 - dialogue_box.height / 2 + dialogue_box.margin.y + reply_offset  + 200 + 40))
			get_node("ui_dialogue/reply" + str(n+1)).num_reply = n
			
			for reply in range(0,replies_size):
				reply_container.push_back("ui_dialogue/reply" + str(n+1))
				get_node("ui_dialogue/reply" + str(n+1)).set_text(replies[n]["reply"])

			var lines = get_node("ui_dialogue/reply" + str(n+1)).get_line_count()
			reply_offset += 25 * lines

	reply_offset = 0

func setup_avatar():
	if branch.has("avatar"):
		if branch["avatar"].ends_with("tscn"):
			avatar_type = "animated"
			avatar = load(branch["avatar"])
			avatar_frame = branch["frame"]
			avatar = avatar.instance()
			avatar.frame = avatar_frame
			avatar.set_scale(Vector2(0.7,0.7))
			avatar.set_position(Vector2(VIEWSIZE.x/2 - dialogue_box.width/2, VIEWSIZE.y - dialogue_box.posy + 200))
		else:
			# if doesn´t end with TSCN, it´s a sprite
			avatar_type = "static"
			var texture = ImageTexture.new()
			var image = Image.new()
			var sprite = Sprite.new()
			image.load(branch["avatar"])
			texture.create_from_image(image)
			sprite.texture = texture
			avatar = sprite
			avatar.set_position(Vector2(VIEWSIZE.x/2 - dialogue_box.width/2, VIEWSIZE.y - dialogue_box.posy + 200))	
				
		$"ui_dialogue".add_child(avatar)
	else:
		avatar = null
		
		
func create_labels(labels):
	kill_dialogue()
	for lbl in labels:
		if lbl == "panel":
			var node := Panel.new()
			node.set_name(lbl)
			$"ui_dialogue".add_child(node)
		if lbl == "dialogue":
			var node = dialogue_window.instance()
			node.set_name(lbl)
			node.connect("dialogue_clicked", self, "dialogue_clicked")
			$"ui_dialogue".add_child(node)
		if page_index == dialogue_text_size-1:
			if "reply" in lbl:
				var node = reply_button.instance()
				node.set_name(lbl)
				node.connect("reply_selected",self,"pick_reply",[], CONNECT_ONESHOT)
				node.connect("reply_mouseover",self,"_reply_mouseover")
				$"ui_dialogue".add_child(node)

func kill_dialogue():
	for x in $"ui_dialogue/".get_children():
		x.set_name("DELETED") #to make sure node doesn´t cause issues before being deleted
		x.queue_free()
		
	reply_container = []
	global.dialogue_waiting = false
