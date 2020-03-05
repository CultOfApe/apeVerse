extends Node2D

#TODO: selecting reply on single reply dialogue, doesnt select replies. Set so if dialogue text and replies are displayed
#enter automatically choses first reply?

#some of the below cannot be cast as dictionaries, because of array and dictionary mixing in the code
onready var dialogPanel 	: Object  = load("res://data/asset scenes/dialogue_window.tscn")
onready var replyButton 	: Object  = load("res://data/asset scenes/reply.tscn")
onready var screenBlur 		: Object = $"../effects/blurfx"
onready var effectBlurUI 	: Object = $"../effects/tween"

var npcDialogue 	: Dictionary
var dialogue 		: Dictionary
var dialogBox 		: Dictionary
var talkData 		= {}
var branch 			= {}
var replies 		= {}

var dialogueType

onready var VIEWSIZE : Vector2 = get_viewport_rect().size

var npcName 		: String
var talkAnim 		= null
var npc 			: String

var numDialogueText : int = 0
var numReplies 		: int = 0
var pageIndex 		: int = 0
var replyContainer 	: Array
var replyMouseover 	: bool = false
var replyCurrent 	: int = -1

var mousePos 		: Vector3

var talkAnimFrame 	: int

func _ready():
	set_process_input(true)
	
	# TODO: This is getting better but should be loaded from json, and needs further adjustable variables, like offset from bottom of screen, pos of avatar/name etc.
	dialogBox = {"width": 1000, "height": 60, "margin": Vector2(100, 20), "posx": VIEWSIZE.x / 2, "posy": VIEWSIZE.y / 2}
		
	for object in get_parent().get_node("npcs").get_children():
		object.connect("dialogue", self, "_talk_to")
		
func event_handler():
	pass

func _input(event):
	if global.dialogue_running == true and replyMouseover == false:
		#TODO: This cycles through reply choices with W(ui_up) and S(ui_down) butno way of confirming selection yet
		if event.is_action_pressed("ui_down") and replyCurrent != numReplies-1:
			replyCurrent += 1
			for reply in replyContainer:
				var node = get_node(reply)
				node.add_color_override("font_color", Color(1,1,1))
			get_node(replyContainer[replyCurrent]).add_color_override("font_color", Color(1,0,1))
		if event.is_action_pressed("ui_up") and replyCurrent != 0:
			replyCurrent -= 1
			for reply in replyContainer:
				var node = get_node(reply)
				node.add_color_override("font_color", Color(1,1,1))
			get_node(replyContainer[replyCurrent]).add_color_override("font_color", Color(1,0,1))
		#TODO: not working like it should. Look over, old code.
		if event.is_action_pressed("ui_accept"):
			if replyCurrent != -1:
				if get_node(replyContainer[replyCurrent]).text == "exit dialogue":
					effectBlurUI.interpolate_property(screenBlur, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
					kill_dialogue()
				else:
					_pick_reply(replyCurrent)
			if pageIndex < numDialogueText-1:    
				pageIndex += 1
				start_dialogue(global.charData[npc]["dialogue"][dialogueType]["path"], dialogueType)
			if pageIndex < numDialogueText-1:    
				pageIndex += 1
				start_dialogue(global.charData[npc]["dialogue"][dialogueType]["path"], dialogueType)
			if pageIndex == numDialogueText-1 and numReplies == 0:
				kill_dialogue()
			
func _dialogue_clicked():
	if pageIndex < numDialogueText-1:    
		pageIndex += 1
		start_dialogue(global.charData[npc]["dialogue"][dialogueType]["path"], dialogueType)
	#if there are no replies - exit dialogue
	if pageIndex == numDialogueText-1 and numReplies == 0:
		global.dialogue_running = false
		kill_dialogue()

func _talk_to(id, npcPos, type):
	#TODO: only able to speak to NPCs within arbitrary distance. If not able, notify player (thought bubble?)
	var player_pos 	: Vector3 = get_parent().get_node("player").get_global_transform().origin
	#TODO: Ideally, if player is too far from NPC, he should move closer and then start dialogue, but this is enough for now
	if player_pos.distance_to(npcPos) < 4:
		global.blocking_ui = true
		npc = id
		dialogueType = type
		effectBlurUI.interpolate_property(screenBlur, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		get_parent().get_node("ui").toggle_ui_icons("hide")
		start_dialogue(global.charData[id]["dialogue"][dialogueType]["path"], dialogueType)
	else:
		get_parent().thought_bubble("Too far away for that.")
		print("Too far away for that.")

func _pick_reply(n):
	replyCurrent =-1
	
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
		
		var eventCache = global.load_json("res://data/events/" + replies[n]["event"][0]["id"] + ".json")
		
		var today = global.day
		var currentWeekday = global.gameData["daycount"][global.weekday]
		var eventDay
		var eventWeekday
		
		#what´s the weekday of the event?
		if eventCache["weekday"] != "same":
			eventDay = global.day + global.gameData["daycount"][eventCache["weekday"]] - today
			eventWeekday = global.gameData["weekday"][eventDay - 1]
		else:
			eventWeekday = global.weekday
			eventDay = global.day

		var event_class = {
			eventCache["timeofday"] : {"event":eventCache["event"], 
			"type": eventCache["type"], 
			"icon": eventCache["calendar"]["icon"]}
			}
		
		global.eventData["date"][str(eventDay)] = event_class
		
		# This code is still untested, since event system is not yet complete
		# TODO: cycle through more than one actor, and delete actors marked for removal
		if global.eventData["date"][str(eventDay)][eventCache["timeofday"]]["type"] == "persistent":	
			global.locData[eventCache["calendar"]["location"]]= {	
				eventCache["weekday"]: {
					eventCache["timeofday"]: {
						"actors": {
							eventCache["add"]["actor"][0]["id"]: {

								"dialogue": eventCache["add"]["actor"][0]["dialogue"],
								"branch": eventCache["add"]["actor"][0]["branch"],
								"pose": eventCache["add"]["actor"][0]["model"] + ".scn",
								"pos": {
									"x": eventCache["add"]["actor"][0]["pos"]["x"],
									"y": eventCache["add"]["actor"][0]["pos"]["y"],
									"z": eventCache["add"]["actor"][0]["pos"]["z"]},
								"rot": {
									"x": eventCache["add"]["actor"][0]["rot"]["x"],
									"y": eventCache["add"]["actor"][0]["rot"]["y"],
									"z": eventCache["add"]["actor"][0]["rot"]["z"]}
							}

						}
					}
				}
					
			}
			
		# TODO: check if date is already present in eventData, and alert player if so
		if global.eventData["date"][str(eventDay)][eventCache["timeofday"]]["type"] == "oneoff":	
			pass
				
	# if there is a progress array in json, update game progression variables
	if replies[n].has("progress"):
		# TODO: if progress has a location - update global.sceneData override instead of charData
		for item in range(0, replies[n]["progress"].size()):
			var affected = replies[n]["progress"][item]["name"]
			
			# TODO: allow for dialogue change for specific locations
			if replies[n]["progress"][item]["dialogue"].ends_with("phone.json"):
				global.charData[affected]["dialogue"]["phone"]["path"] = replies[n]["progress"][item]["dialogue"]
				global.charData[affected]["dialogue"]["phone"]["branch"] = replies[n]["progress"][item]["branch"]
			else:
				global.charData[affected]["dialogue"]["default"]["path"] = replies[n]["progress"][item]["dialogue"]
				global.charData[affected]["dialogue"]["default"]["branch"] = replies[n]["progress"][item]["branch"]
			
	# TODO: a reply can trigger a change of location(and time)
	if replies[n].has("goto"):	
		pass
							
	#if "exit" is "false" take value from "next" and start next dialogue
	if replies[n]["exit"] != "true":
		if replies[n]["next"].ends_with(".json"):

			# TODO: start_dialogue("res://data/dialogue/" + charData[npc]["dialogue"]) + charData[npc]["relationship"] + (".json")
			start_dialogue(global.charData[npc]["dialogue"][dialogueType]["path"], dialogueType)
		else:					
			global.charData[npc]["dialogue"][dialogueType]["branch"] = replies[n]["next"]
			pageIndex = 0
			start_dialogue(global.charData[npc]["dialogue"][dialogueType]["path"], dialogueType)
		
	
	#if "exit" is "true", kill dialogue
	else:
		pageIndex = 0
		
		if replies[n]["next"].ends_with(".json"):
			global.charData[npc]["dialogue"][dialogueType]["path"] = replies[n]["next"]
		else:
			global.charData[npc]["dialogue"][dialogueType]["branch"] = replies[n]["next"]
			
		effectBlurUI.interpolate_property(screenBlur, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		global.dialogue_running = false
		kill_dialogue()
		global.blocking_ui = false
		global.sceneCol.disabled = false
		get_parent().get_node("ui").toggle_ui_icons("show")
		
		if replies[n].has("bubble"):
			get_parent().thought_bubble(replies[n]["bubble"])
		
		global.change_cursor("default")
	
func _reply_mouseover(mouseover, reply):
	if mouseover == true:
		replyMouseover = true
		replyCurrent = reply
	elif mouseover == false:
		replyMouseover = false
		replyCurrent = -1

func start_dialogue(json, type):

	var cursor = load("res://data/graphics/cursor_arrow.png")
	Input.set_custom_mouse_cursor(cursor)
	
#	TODO: when calling a dialogue, call start_dialogue("ellie_date_0" + str(global.chardata["relationship"]) + ".json")
	global.dialogue_running = true
	
	talkData = global.load_json(json)
	
	branch = talkData["dialogue"][global.charData[npc]["dialogue"][type]["branch"]]
	replies = talkData["dialogue"][global.charData[npc]["dialogue"][type]["branch"]]["replies"]
	
#	print(npc + " json: " + json)
	
	npcName = talkData["name"]
	
	if branch.has("avatar"):
		talkAnim = load(branch["avatar"])
		talkAnimFrame = branch["frame"]
	else:
		talkAnim = null

	numDialogueText = branch["speech"].size()
	
	# if branch has replies, check how many. If no responses, numReplies is 0
	if branch.has("replies"):
		numReplies = replies.size()
	else:
		replyMouseover = false
		numReplies = 0
	
	#TODO: This condition should decide if to open dialogue in window, or display dialogue over character heads. Low priority..
	if branch.has("window"):
		pass
		
	#TODO: This condition currently only handles exact values, needs to evaluate if value is above another value too (ex money)
	#0 is variable to check for
	#1 is value of variable, and if that variable corresponds to gameVars, set 2 as current dialogue
	#2 is target conversation (dialogue or branch)
	#thebelow block of code checks if a condition in gameVars is met, and changes dialogue accordingly if it is
	if branch.has("condition"):
		for item in branch["condition"]:
			if global.gameVars.has(branch["condition"][item][0]):
				if global.gameVars[branch["condition"][item][0]] == branch["condition"][item][1]:
					if branch["condition"][item][2].ends_with("json"):
						global.charData[talkData["name"]]["dialogue"][dialogueType]["path"] = branch["condition"][item][2]
					else:
						global.charData[talkData["name"]]["dialogue"][dialogueType]["branch"] = branch["condition"][item][2]
	
	setup_dialogue_window()
	
	#set text and reply in dialogue panel
	$"ui_dialogue/dialogue/name".set_text(npcName)
	$"ui_dialogue/dialogue".set_text(branch["speech"][pageIndex])
	
	if pageIndex == numDialogueText-1 and numReplies > 0:
		for n in range(0,numReplies):
			replyContainer.push_back("ui_dialogue/reply" + str(n+1))
			get_node("ui_dialogue/reply" + str(n+1)).set_text(replies[n]["reply"])
		
func setup_dialogue_window():
		
	var reply_offset 	: int 	= 0
	var labels 			: Array = ["panel","dialogue"]
	
	#add one element "reply" per number of replies in talkData
	for n in range(numReplies):
		labels.push_back("reply" + str(n+1))
	
	create_labels(labels)
	
	# TODO: The below could be made even more dynamic. Has some arbitrary values that don´t really work if we want diferent sized windows
	$"ui_dialogue/panel".set_size(Vector2(dialogBox.width, dialogBox.height + numReplies*30))
	$"ui_dialogue/panel".set_position(Vector2(VIEWSIZE.x /2 - dialogBox.width / 2, VIEWSIZE.y / 2 - dialogBox.height / 2 + 200))
	$"ui_dialogue/panel".modulate.a = 0.5
	
	$"ui_dialogue/dialogue".set_size(Vector2(dialogBox.width, dialogBox.height + numReplies * 30))
	$"ui_dialogue/dialogue".set_position(Vector2(VIEWSIZE.x / 2 - dialogBox.width / 2 + dialogBox.margin.x, 
												 VIEWSIZE.y / 2 - dialogBox.height / 2 + dialogBox.margin.y + 200))
	
	if pageIndex == numDialogueText-1 and numReplies > 0:
		for n in range(numReplies):
			get_node("ui_dialogue/reply" + str(n+1)).set_size(Vector2(400, 50))
			get_node("ui_dialogue/reply" + str(n+1)).set_position(Vector2(VIEWSIZE.x /2 - dialogBox.width / 2 + dialogBox.margin.x, 
																		  VIEWSIZE.y / 2 - dialogBox.height / 2 + dialogBox.margin.y + reply_offset  + 200 + 40))
			get_node("ui_dialogue/reply" + str(n+1)).num_reply = n
			reply_offset += 30
	
	#TODO: this should be set dynamically by the json dialogue file
	if talkAnim != null:
		talkAnim = talkAnim.instance()
		talkAnim.frame = talkAnimFrame
		talkAnim.set_scale(Vector2(0.7,0.7))
		talkAnim.set_position(Vector2(VIEWSIZE.x/2 - dialogBox.width/2, VIEWSIZE.y - dialogBox.posy + 200))
		$"ui_dialogue".add_child(talkAnim)

	reply_offset = 0

func create_labels(labels):
	kill_dialogue()
	for lbl in labels:
		if lbl == "panel":
			var node = Panel.new()
			node.set_name(lbl)
			$"ui_dialogue".add_child(node)
		if lbl == "dialogue":
			var node = dialogPanel.instance()
			node.set_name(lbl)
			node.connect("dialogueClicked", self, "_dialogue_clicked")
			$"ui_dialogue".add_child(node)
		if pageIndex == numDialogueText-1:
			if "reply" in lbl:
				var node = replyButton.instance()
				node.set_name(lbl)
				node.connect("reply_selected",self,"_pick_reply",[], CONNECT_ONESHOT)
				node.connect("reply_mouseover",self,"_reply_mouseover")
				$"ui_dialogue".add_child(node)

func kill_dialogue():
	for x in $"ui_dialogue/".get_children():
		x.set_name("DELETED") #to make sure node doesn´t cause issues before being deleted
		x.queue_free()
		
	replyContainer = []
