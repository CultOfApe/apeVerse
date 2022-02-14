extends Control

onready var screen_blur := $"../effects/blurfx"
onready var click_node 	:= load("res://data/editor/assets/node_click_button.tscn") #PackedScene
onready var editor_node := load("res://data/editor/assets/Editor_panel_label.tscn") #PackedScene
onready var SCREENSIZE 	:= get_viewport().get_visible_rect().size

var current_dialogue	: String
var current_path		: String
var current_branch		: String
var previous_branch 	: String
var reverse 			:= false
var previous_session 	:= false
var active_npc			: String
var current_animation	: AnimatedSprite	
var current_frame		: int

var session_log 	:= {} # Array containing reference to all current nodes in dialogue tree, hierarchically
var nodes_origin

var JSON_files 	: Array

func _ready():
	pass

func _input(event):
	#show or hide editor
	if event.is_action_pressed("ui_editor"):
		if !global.editor:
			self.show()
			_setup_editor()						
		elif global.editor:
			_kill_editor()
			screen_blur.modulate = Color(1, 1, 1, 0)
	
func _setup_editor():
	global.change_cursor("arrow")
	
	global.editor_lvl 	= 1
	global.blocking_ui 	= true
	global.editor 		= true
	global.files 		= []

	screen_blur.modulate = Color(1, 1, 1, 1)

	#TODO: if a previous session has been initiated, remember and open with previous nodes visible
	if previous_session == false:
		for node in get_tree().get_nodes_in_group("editor_main"):
			node.hide()

	var json_folder : Array = global.list_files_in_directory("res://data/dialogue/json")
	for item in json_folder:
		JSON_files.push_back(item)

	_create_new_UI_element("json_files", VBoxContainer, self, 0, 0, 0, 0)	

	for i in range(JSON_files.size()):
		_create_instanced_UI_element("json_files_b" + str(i), click_node, $"json_files", 0, 0, 0, 0, null)

	for i in range(JSON_files.size()):
		get_node("json_files/json_files_b" + str(i)).id = JSON_files[i]
		get_node("json_files/json_files_b" + str(i)).branch = "1"
		get_node("json_files/json_files_b" + str(i)).set_text(JSON_files[i])
		get_node("json_files/json_files_b" + str(i)).connect("on_click",self,"_pop_nodes",[], CONNECT_ONESHOT)
		get_node("json_files/json_files_b" + str(i)).connect("button_hover",self,"_button_hover")	
		
func _kill_editor():			
	global.change_cursor("default")
			
	get_node("json_files").queue_free()
	if get_node("nodes"):
		get_node("nodes").queue_free()
	
	JSON_files.clear()
		
	for node in get_tree().get_nodes_in_group("editor_main"):
		node.hide()
		
	global.blocking_ui = false
	global.editor = false
	global.editor_lvl = 0

func _create_new_UI_element(id, type, parent, xsize, ysize, xpos, ypos): # add variable to cancel instancing, or instance outside of func(?)
	var node = type.new()
	node.set_name(id)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("on_click",self,"_on_node_click")
	if parent != null:
		parent.add_child(node) 
	
func _create_instanced_UI_element(id, type, parent, xsize, ysize, xpos, ypos, margin): # add variable to cancel instancing, or instance outside of func(?)
	var node = type.instance()
	node.set_name(id)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("on_click",self,"_on_node_click")
	if parent != null:
		parent.add_child(node) 

# TODO: If existing nodes, spawn new nodes at x + 1080, and then move over $"nodes" x -1080
func _pop_nodes(id, branch, reset, modifier):

	for node in get_tree().get_nodes_in_group("editor_main"):
		node.show()
	
	$json_files.set_position(Vector2(($json_files.get_position() - Vector2(150, 0))))
	
	if reset:
		if $"nodes":
			$"nodes".queue_free()
			$"nodes".set_name("DELETED")
			
	if !$"nodes":
		var nodeContainer = Position2D.new()
		nodeContainer.set_name("nodes")
		self.add_child(nodeContainer)	
		
	if session_log == {}:
		nodes_origin = $nodes.get_position()
	
	current_dialogue = id
	
	# only run when first opening dialogue
	if !session_log.has(current_dialogue):
		print("hussah!")
		session_log = {current_dialogue : [branch],
					"active" : 0}
					
	# FIX: this shouldn´t be run if we traverse backwards in the nodetree. Do we need another flag? :P
	elif session_log[current_dialogue].back() != branch: #and reverse != true:
		session_log[current_dialogue].push_back(branch)
		
	session_log["active"] += modifier
	
	print(session_log)
	print("current dialogue: " + current_dialogue)
		
	if session_log[current_dialogue].size() > 1:
		previous_branch = str(session_log[current_dialogue][(session_log.active) - 1])
	
	reverse = false
	current_branch 	= str(session_log[current_dialogue][session_log.active])
	
	var node = global.load_json("res://data/dialogue/json/" + id)
	
	var root = Node2D.new()
	root.set_name(branch)
	$"nodes".add_child(root)

	change_avatar(node.dialogue, node.dialogue["1"].avatar, "branch")
	
	_create_instanced_UI_element("dialogue", editor_node, get_node("nodes/" + branch), 400, 300, SCREENSIZE.x/2 - 200, SCREENSIZE.y/2 - 150, 10)		
#	get_node("dialogueNode/Label").id(id)
	get_node("nodes/" + branch + "/dialogue/Label").set_size(Vector2(380,280))
	get_node("nodes/" + branch + "/dialogue/Label").set_position(Vector2(10,10))
	get_node("nodes/" + branch + "/dialogue/Label").set_text(node["dialogue"][branch]["speech"][0])
	get_node("nodes/" + branch + "/dialogue").nodetype = "dialogue"
	get_node("nodes/" + branch + "/dialogue").id = branch
	get_node("nodes/" + branch + "/dialogue/Label/Edit").set_size(Vector2(380,280))
	get_node("nodes/" + branch + "/dialogue/Label/Edit").set_text(node["dialogue"][branch]["speech"][0])

#	TODO: set avatar from dialogue data
#	$avatar.set_animation(session_log[current_dialogue][session_log.active]) 
#	["dialogue"][global.charData[npc]["dialogue"][type]["branch"]]

	var replies_size = node["dialogue"][branch]["replies"].size()

	var offset = ((replies_size + 1) * 100 + (replies_size + 1) * 25 - 25) / 2
	
	if session_log.has(current_dialogue): #and session_log[current_dialogue].size() != 1:

#		print("----------------------------")
#		print("DEBUG Editor.gd")
#		print("----------------------------")
#		print(" ")	
#		print(" " + String(session_log))
#		print(" This chain has " + str(session_log[current_dialogue].size()) + " nodes and the current node has index no. " + str(session_log[current_dialogue].size() -1))
#		print(" current node has value: " + session_log[current_dialogue][session_log[current_dialogue].size() - 1])
#		print(" and has " + String(node["dialogue"][session_log[current_dialogue][(session_log.active) - 1]]["replies"].size()) + " replies")
#		print(" ")	
#		print("----------------------------")
#		print("DEBUG end")
#		print("----------------------------")
#		print(" ")	
	
		if session_log.active != 0: # calc by active-1 instead
#			print("previous node has value: " + previous_branch)
			var previous_replies_size = node["dialogue"][session_log[current_dialogue][(session_log.active) - 1]]["replies"].size()
			var previous_offset = (previous_replies_size * 100 + previous_replies_size * 25 - 25) / 2
	
			for i in previous_replies_size:
				var oldroot = Node2D.new()
				oldroot.set_name(previous_branch)
				$"nodes".add_child(oldroot)
				var next = node["dialogue"][previous_branch]["replies"][i]["next"]
	#			print(next)
				
				# This is not working as well as I thought. While it displays previous replies, clicking around sometimes produces unexpected results...
				# need variable for last reply, make so when you click it, it takes you back, whereas the other replies don´t
				_create_instanced_UI_element(str(i), editor_node, get_node("nodes/" + previous_branch), 300, 100, SCREENSIZE.x/2 -600, SCREENSIZE.y/2 + (i * 125) - previous_offset, 10)
				
				get_node("nodes/" + previous_branch + "/" + str(i)).dialogue = {"file": id, "branch": previous_branch, "reply": i}
				if next != current_branch:
					get_node("nodes/" + previous_branch + "/" + str(i)).branch = next
				else:
					get_node("nodes/" + previous_branch + "/" + str(i)).branch = previous_branch
					get_node("nodes/" + previous_branch + "/" + str(i) + "/Label").add_color_override("font_color", Color(1,0,0))
				get_node("nodes/" + previous_branch + "/" + str(i)).reply = ""
				get_node("nodes/" + previous_branch + "/" + str(i)).modifier = -1
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label").set_size(Vector2(280,80))
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label").set_position(Vector2(10,10))
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label").set_text(node["dialogue"][previous_branch]["replies"][i]["reply"]) #crashes if one reply only. Rethink
				get_node("nodes/" + previous_branch + "/" + str(i)).nodetype = "reply"
				get_node("nodes/" + previous_branch + "/" + str(i)).id = str(i)
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label/Edit").set_size(Vector2(280,80))
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label/Edit").set_text(node["dialogue"][previous_branch]["replies"][i]["reply"])

	# run for number of replies
	for i in (replies_size + 1):
		
		var trunk = "nodes/" + branch + "/" + str(i)
		
		# add boxes for replies
		if i < replies_size:
			var next = node["dialogue"][branch]["replies"][i]["next"]
		
			_create_instanced_UI_element(str(i), editor_node, get_node("nodes/" + branch), 300, 100, SCREENSIZE.x/2 + 300, SCREENSIZE.y/2 + (i * 125) - offset, 10)
			
#			get_node(trunk).dialogue = {"file": id, "branch": current_branch, "reply": i}
			get_node(trunk).dialogue = current_dialogue
			get_node(trunk).branch = next
			get_node(trunk).reply = ""
			get_node(trunk).modifier = 1
			if node["dialogue"][branch]["replies"][i]["exit"] == "true":
				get_node(trunk).active = false
			else:
				get_node(trunk).active = false
			get_node(trunk + "/Label").set_size(Vector2(280,80))
			get_node(trunk + "/Label").set_position(Vector2(10,10))
			get_node(trunk + "/Label").set_text(node["dialogue"][branch]["replies"][i]["reply"])
			get_node(trunk).nodetype = "reply"
			get_node(trunk).id = str(i)
			get_node(trunk + "/Label/Edit").set_size(Vector2(280,80))
			get_node(trunk + "/Label/Edit").set_text(node["dialogue"][branch]["replies"][i]["reply"])
					
		# last box is to add new reply
		else: 
			_create_instanced_UI_element(str(i), editor_node, get_node("nodes/" + branch), 300, 100, SCREENSIZE.x/2 + 300, SCREENSIZE.y/2 + (i * 125) - offset, 10)
			get_node(trunk + "/Label").set_size(Vector2(280,80))
			get_node(trunk + "/Label").set_position(Vector2(10,10))
			get_node(trunk).nodetype = "add"
			get_node(trunk).id = "add"
			get_node(trunk).dialogue = current_dialogue
			get_node(trunk + "/Label/Edit").set_size(Vector2(280,80))
			get_node(trunk + "/Label/Edit").set_text("")
			get_node(trunk + "/Label").hide()
			get_node(trunk + "/add").show()
		
		# CHECK save editor session to cache, only save to file if explicitly stated
		global.editorData[current_dialogue] = session_log
		if !global.editorData[current_dialogue].has("cache"):
			global.editorData[current_dialogue]["cache"] = global.load_json("res://data/dialogue/" + id)

func change_avatar(dialogue, sprite, branch):
	if dialogue[session_log[current_dialogue][(session_log.active) - 1]].has("avatar"):
		get_node("main/avatar/avatar").queue_free()
		get_node("main/avatar/avatar").set_name("DELETED")
		var avatar = load(sprite)
		avatar = avatar.instance()	
		avatar.set_name("avatar")
		avatar.frame = dialogue[session_log[current_dialogue][(session_log.active) - 1]]["frame"]
		$main/avatar.add_child(avatar)
		var avatar_pos = $main/avatar.get_global_position()
		var frames = $main/avatar/avatar.frames
		var texture = frames.get_frame("default", avatar.frame)
		$main/avatar.set_global_position(avatar_pos) #BAD: hardcoded
		$main/avatar.id = sprite
	
func _on_node_click(branch, null, modifier):
	#TODO: shouldn´t be called if node has same id as current branch
#	print("-------------------------------")
	if modifier == -1:
		reverse = true
	else:
		reverse = false
	if branch == current_branch:
		modifier = 0
	_pop_nodes(current_dialogue, branch, true, modifier)

	
func _reply_clicked(a):
	pass	
	
func _button_hover():
	pass

func _on_help_toggled(button_pressed):
	if button_pressed:
		$main/keymap.show()
	else:
		$main/keymap.hide()

func _on_advanced_toggled(button_pressed):
	if button_pressed:
		for node in get_tree().get_nodes_in_group("editor_advanced"):
			node.show()
	else:
		for node in get_tree().get_nodes_in_group("editor_advanced"):
			node.hide()

func _on_saveSessionToFile_pressed():
	var file = File.new()
	file.open("user://session.save", File.WRITE)
	file.store_line(to_json(session_log))
	file.close()
	
func _on_openSessionFromFile_pressed():
	pass # Replace with function body.

#TODO: references dictionary local to editorNode.gd. Needs solution.
func _on_setToActive_pressed():
	pass
#	var dir = Directory.new()
#	dir.copy("res://data/dialogue/json/" + dialogue, "res://data/editor/backup/" + dialogue + ".bak")
#	global.charData[npc]["dialogue"][type]["branch"]]["replies"]
#	global.editorData[dialogue["file"]]["cache"]

func _on_resetActiveDialogue_pressed():
	global.charData["ellie"]["dialogue"]["default"]["branch"] = "1"

#	expands dialogue tree. Wonky righ now, so v
func _on_expand_pressed():

	$json_files.set_position(Vector2(($json_files.get_position() + Vector2(150, 0))))
	$nodes.set_position(Vector2($nodes.get_position() + Vector2(150, 0)))
	$main.set_position(Vector2($main.get_position() + Vector2(150, 0)))
	$expand.hide()
