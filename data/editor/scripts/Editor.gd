extends Control

onready var blur_shader := $"/root/game/ui/shaders/blur"
onready var click_node 	:= load("res://data/editor/assets/node_click_button.tscn") #PackedScene
onready var editor_node := load("res://data/editor/assets/Editor_panel_label.tscn") #PackedScene
onready var dialogue_trees = $"dialogue_picker/dialogue_trees"
onready var dialogue_branches = $"dialogue_picker/dialogue_branches"
onready var SCREENSIZE 	:= get_viewport().get_visible_rect().size

var current_dialogue	: String
var current_path		: String
var current_branch		: String
var previous_branch 	: String
var reverse 			:= false
var previous_session 	:= false
var active_npc			: String
var current_avatar_path	: String
var current_animation	: AnimatedSprite	
var current_frame		: int
var dialogue_size 		: int

var session_log 	:= {} 	# Record of dialogue progression
var session_cache			# Copy of the active dialogue tree
var nodes_origin			# First position of nodes

var JSON_files 	: Array

func _ready():
	get_node("main/avatar").connect("avatar_changed", self, "save_avatar")
	print(dialogue_trees.name)
	print(dialogue_branches.name)

func _input(event):
	#show or hide editor
	if event.is_action_pressed("ui_editor"):
		if !global.editor:
			self.show()
			_setup_editor()						
		elif global.editor:
			_kill_editor()
			blur_shader.modulate = Color(1, 1, 1, 0)
	
func _setup_editor():
	global.change_cursor("arrow")
	
	global.editor_lvl 	= 1
	global.blocking_ui 	= true
	global.editor 		= true

	blur_shader.modulate = Color(1, 1, 1, 1)

	#TODO: if a previous session has been initiated, remember and open with previous nodes visible
	if previous_session == false:
		for node in get_tree().get_nodes_in_group("editor_main"):
			node.hide()

	var json_folder : Array = global.list_files_in_directory("res://data/dialogue/json")
	for item in json_folder:
		JSON_files.push_back(item)

	# TODO: instead of starting dialogue, populate dialogue branches vbox
	for i in range(JSON_files.size()):
		_create_instanced_UI_element("json_files_b" + str(i), click_node, dialogue_trees, 0, 0, 0, 0, null)

	for i in range(JSON_files.size()):
		dialogue_trees.get_node("json_files_b" + str(i)).id = JSON_files[i]
		dialogue_trees.get_node("json_files_b" + str(i)).branch = "1"
		dialogue_trees.get_node("json_files_b" + str(i)).set_text(JSON_files[i])
		dialogue_trees.get_node("json_files_b" + str(i)).connect("on_click",self,"new_dialogue",[], CONNECT_ONESHOT)
		dialogue_trees.get_node("json_files_b" + str(i)).connect("on_hover",self,"hover_dialogue")	
		dialogue_trees.get_node("json_files_b" + str(i)).add_to_group("dialogue_select")
		
	pop_branch_tree("ellie.json")

func hover_dialogue(flag, id):
	if flag == true:
		for node in $dialogue_picker/dialogue_branches.get_children():
			node.queue_free()
		pop_branch_tree(id)
	
func pop_branch_tree(id):
	
	var tree = global.load_json("res://data/dialogue/json/" + id)
#	var branch_cache = global.load_json("res://data/dialogue/json/" + current_dialogue)
	
	for i in range(tree.dialogue.size()):
		_create_instanced_UI_element("branch" + str(i+1), click_node, dialogue_branches, 0, 0, 0, 0, null)

	for i in range(tree.dialogue.size()):
		dialogue_branches.get_node("branch" + str(i+1)).id = id
		dialogue_branches.get_node("branch" + str(i+1)).branch = str(i+1)
		dialogue_branches.get_node("branch" + str(i+1)).set_text(tree.dialogue[str(i+1)]["speech"][0].left(25))
		dialogue_branches.get_node("branch" + str(i+1)).connect("on_click",self,"new_dialogue",[], CONNECT_ONESHOT)
#		dialogue_branches.get_node("branch" + str(i+1)).connect("button_hover",self,"_button_hover")
#		print("tree: " + id)
#		print("branch: " + str(i+1))
#		print("text: " + tree.dialogue[str(i+1)]["speech"][0].left(25))

		
func _kill_editor():			
	global.change_cursor("default")
			
	get_node("dialogue_picker/dialogue_trees/").queue_free()
	get_node("dialogue_picker/dialogue_branches/").queue_free()
	if get_node("nodes"):
		get_node("nodes").queue_free()
	
	JSON_files.clear()
		
	for node in get_tree().get_nodes_in_group("editor_main"):
		node.hide()
		$head.hide()
		
	global.blocking_ui = false
	global.editor = false
	global.editor_lvl = 0

func _create_new_UI_element(id, type, parent, xsize, ysize, xpos, ypos): # add variable to cancel instancing, or instance outside of func(?)
	var node = type.new()
	node.set_name(id)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("on_click", self, "_on_node_click")
	node.connect("on_hover", self, "_button_hover")	
	if parent != null:
		parent.add_child(node) 
	
func _create_instanced_UI_element(id, type, parent, xsize, ysize, xpos, ypos, margin): # add variable to cancel instancing, or instance outside of func(?)
	var node = type.instance()
	node.set_name(id)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("on_click", self, "_on_node_click")
	node.connect("on_hover", self, "_button_hover")	
	node.connect("save_edit", self, "_save_edit")	
	if parent != null:
		parent.add_child(node) 

func new_dialogue(id, branch, reset, modifier):
	current_dialogue = id
	session_cache = global.load_json("res://data/dialogue/json/" + current_dialogue)
	dialogue_size = session_cache["dialogue"].size()
	_pop_nodes(id, branch, reset, modifier)

# TODO: If existing nodes, spawn new nodes at x + 1080, and then move over $"nodes" x -1080
func _pop_nodes(id, branch, reset, modifier):
	
	for node in get_tree().get_nodes_in_group("editor_main"):
		node.show()
	
	# Hide away json files
	# TODO: twee animation
	$dialogue_picker.set_position(Vector2(($dialogue_picker.get_position() - Vector2(150, 0))))
		
	# CHECK: Is this needed? We always reset?
	if reset:
		if $"nodes":
			$"nodes".queue_free()
			$"nodes".set_name("DELETED")
	
	# CHECK: same here. We always create this anyway?	
	if !$"nodes":
		var nodeContainer = Position2D.new()
		nodeContainer.set_name("nodes")
		self.add_child(nodeContainer)	
	
	# CHECK: Same here. Why do this?
	if session_log == {}:
		nodes_origin = $nodes.get_position()
	
	# only run when first opening dialogue, and no current dialogue has been set
	if !session_log.has(current_dialogue):
		session_log = {current_dialogue : [branch],
					"active" : 0, "name" : session_cache.name.to_lower()}
					
	# FIX: this shouldn´t be run if we traverse backwards in the nodetree. Do we need another flag? :P
	elif session_log[current_dialogue].back() != branch: #and reverse != true:
		session_log[current_dialogue].push_back(branch)
		
	session_log["active"] += modifier
		
	if session_log[current_dialogue].size() > 1:
		previous_branch = str(session_log[current_dialogue][(session_log.active) - 1])
	
	reverse = false
	current_branch 	= str(session_log[current_dialogue][session_log.active])
	
	var root = Node2D.new()
	root.set_name(branch)
	$"nodes".add_child(root)

	if session_cache.dialogue["1"].has("avatar"):
		$"main/avatar".dialogue = current_dialogue
		$"main/avatar".branch = current_branch
		$"main/avatar".show()
		change_avatar(session_cache.dialogue, session_cache.dialogue["1"].avatar, "branch")
	else:
		$"main/avatar".hide()
	
	_create_instanced_UI_element("dialogue", editor_node, get_node("nodes/" + branch), 400, 300, SCREENSIZE.x/2 - 200, SCREENSIZE.y/2 - 150, 10)		
#	get_node("dialogueNode/Label").id(id)
	get_node("nodes/" + branch + "/dialogue/Label").set_size(Vector2(380,280))
	get_node("nodes/" + branch + "/dialogue/Label").set_position(Vector2(10,10))
	get_node("nodes/" + branch + "/dialogue/Label").set_text(session_cache["dialogue"][branch]["speech"][0])
	get_node("nodes/" + branch + "/dialogue").nodetype = "dialogue"
	get_node("nodes/" + branch + "/dialogue").id = branch
	get_node("nodes/" + branch + "/dialogue/Label/Edit").set_size(Vector2(380,280))
	get_node("nodes/" + branch + "/dialogue/Label/Edit").set_text(session_cache["dialogue"][branch]["speech"][0])

	var replies_size = session_cache["dialogue"][branch]["replies"].size()
	var offset = ((replies_size + 1) * 100 + (replies_size + 1) * 25 - 25) / 2
	
	if session_log.has(current_dialogue): #and session_log[current_dialogue].size() != 1:	
		if session_log.active != 0: # calc by active-1 instead
			var previous_replies_size = session_cache["dialogue"][session_log[current_dialogue][(session_log.active) - 1]]["replies"].size()
			var previous_offset = (previous_replies_size * 100 + previous_replies_size * 25 - 25) / 2
	
		# Previous replies
			for i in previous_replies_size:
				var oldroot = Node2D.new()
				oldroot.set_name(previous_branch)
				$"nodes".add_child(oldroot)
				
				var next = session_cache["dialogue"][previous_branch]["replies"][i]["next"]

				_create_instanced_UI_element(str(i), editor_node, get_node("nodes/" + previous_branch), 300, 100, SCREENSIZE.x/2 -600, SCREENSIZE.y/2 + (i * 125) - previous_offset, 10)
				
				get_node("nodes/" + previous_branch + "/" + str(i)).dialogue = {"file": id, "branch": previous_branch, "reply": i}
				if next != current_branch:
					get_node("nodes/" + previous_branch + "/" + str(i)).branch = branch
					get_node("nodes/" + previous_branch + "/" + str(i)).next = next
				else:
					get_node("nodes/" + previous_branch + "/" + str(i)).branch = branch
					get_node("nodes/" + previous_branch + "/" + str(i)).next = previous_branch
					get_node("nodes/" + previous_branch + "/" + str(i) + "/Label").add_color_override("font_color", Color(1,0,0))
				get_node("nodes/" + previous_branch + "/" + str(i)).reply = ""
				get_node("nodes/" + previous_branch + "/" + str(i)).modifier = -1
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label").set_size(Vector2(280,80))
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label").set_position(Vector2(10,10))
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label").set_text(session_cache["dialogue"][previous_branch]["replies"][i]["reply"]) #crashes if one reply only. Rethink
				get_node("nodes/" + previous_branch + "/" + str(i)).nodetype = "reply"
				get_node("nodes/" + previous_branch + "/" + str(i)).id = str(i)
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label/Edit").set_size(Vector2(280,80))
				get_node("nodes/" + previous_branch + "/" + str(i) + "/Label/Edit").set_text(session_cache["dialogue"][previous_branch]["replies"][i]["reply"])

	# run for number of replies
	for i in (replies_size + 1):
		
		var trunk = "nodes/" + branch + "/" + str(i)
		
		# add boxes for replies
		if i < replies_size:
			var next = session_cache["dialogue"][branch]["replies"][i]["next"]
		
			_create_instanced_UI_element(str(i), editor_node, get_node("nodes/" + branch), 300, 100, SCREENSIZE.x/2 + 300, SCREENSIZE.y/2 + (i * 125) - offset, 10)
			
#			get_node(trunk).dialogue = {"file": id, "branch": current_branch, "reply": i}
			get_node(trunk).dialogue = current_dialogue
			get_node(trunk).branch = branch
			get_node(trunk).next = next
			get_node(trunk).reply = i
			get_node(trunk).modifier = 1
			
			# TODO: this can be made cleaner, reused node paths
			if "next" in session_cache["dialogue"][branch]["replies"][i]:
				get_node(trunk).next = session_cache["dialogue"][branch]["replies"][i]["next"]
				get_node(trunk).get_node("advanced/next").pressed = true
			if "exit" in session_cache["dialogue"][branch]["replies"][i]:
				get_node(trunk).exit = session_cache["dialogue"][branch]["replies"][i]["exit"]
				get_node(trunk).get_node("advanced/exit").pressed = true
			if "progress" in session_cache["dialogue"][branch]["replies"][i]:
				get_node(trunk).progress = session_cache["dialogue"][branch]["replies"][i]["progress"]
				get_node(trunk).get_node("advanced/progress").pressed = true
			if "variables" in session_cache["dialogue"][branch]["replies"][i]:
				get_node(trunk).variables = session_cache["dialogue"][branch]["replies"][i]["variables"]
				get_node(trunk).get_node("advanced/variables").pressed = true
			if "event" in session_cache["dialogue"][branch]["replies"][i]:
				get_node(trunk).events = session_cache["dialogue"][branch]["replies"][i]["event"]
				get_node(trunk).get_node("advanced/events").pressed = true
			if "cutscene" in session_cache["dialogue"][branch]["replies"][i]:
				get_node(trunk).cutscene = session_cache["dialogue"][branch]["replies"][i]["cutscene"]
				get_node(trunk).get_node("advanced/cutscene").pressed = true
			if "bubble" in session_cache["dialogue"][branch]["replies"][i]:
				get_node(trunk).bubble = session_cache["dialogue"][branch]["replies"][i]["bubble"]
				get_node(trunk).get_node("advanced/bubble").pressed = true
			
			if session_cache["dialogue"][branch]["replies"][i]["exit"] == "true":
				get_node(trunk).exit = true
				get_node(trunk).active = false
			else:
				get_node(trunk).active = false
			get_node(trunk + "/Label").set_size(Vector2(280,80))
			get_node(trunk + "/Label").set_position(Vector2(10,10))
			get_node(trunk + "/Label").set_text(session_cache["dialogue"][branch]["replies"][i]["reply"])
			get_node(trunk).nodetype = "reply"
			get_node(trunk).id = str(i)
			get_node(trunk + "/Label/Edit").set_size(Vector2(280,80))
			get_node(trunk + "/Label/Edit").set_text(session_cache["dialogue"][branch]["replies"][i]["reply"])
					
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
			get_node(trunk).connect("reply_added", self, "reply_added")
		
		# CHECK save editor session to cache, only save to file if explicitly stated
		global.editorData[current_dialogue] = session_log
		if !global.editorData[current_dialogue].has("cache"):
			global.editorData[current_dialogue]["cache"] = global.load_json("res://data/dialogue/" + id)

func change_avatar(dialogue, path, branch):
	current_avatar_path = path
	if dialogue[session_log[current_dialogue][(session_log.active) - 1]].has("avatar"):
		get_node("main/avatar/avatar").queue_free()
		get_node("main/avatar/avatar").set_name("DELETED")
		var avatar = load(path)
		avatar = avatar.instance()	
		avatar.set_name("avatar")
		avatar.frame = dialogue[session_log[current_dialogue][(session_log.active) - 1]]["frame"]
		$main/avatar.add_child(avatar)
		var avatar_pos = $main/avatar.get_global_position()
		var frames = $main/avatar/avatar.frames
		var texture = frames.get_frame("default", avatar.frame)
		$main/avatar.set_global_position(avatar_pos) #BAD: hardcoded
		$main/avatar.id = path
	
func _on_node_click(branch, reply, modifier):
	if branch == "0":
		branch = str(dialogue_size + 1)
		session_cache["dialogue"][branch] = {}
		session_cache["dialogue"][branch]["avatar"] = current_avatar_path
		session_cache["dialogue"][branch]["animate"] = false
		session_cache["dialogue"][branch]["frame"] = 0
		session_cache["dialogue"][branch]["speech"] = ["Edit this."]
		session_cache["dialogue"][branch]["replies"] = [{
					"reply": "Edit this.",
					"next": "0",
					"exit": "false"
				}]
		# when clicked, need to change next from 0 to new dialogue branch
		session_cache["dialogue"][current_branch]["replies"][reply]["next"] = str(dialogue_size + 1)

	if branch == current_branch:
		modifier = 0
	_pop_nodes(current_dialogue, branch, true, modifier)

# save changes to reply text
func _save_edit(text, type, reply):
	if type == "reply":
		session_cache["dialogue"][current_branch]["replies"][reply]["reply"] = text
	elif type == "dialogue":
		session_cache["dialogue"][current_branch]["speech"][0] = text
	
func save_avatar(branch, avatar):
		session_cache.dialogue[current_branch].frame = get_node("main/avatar/avatar").get_frame()
		
func reply_added(id):
	session_cache["dialogue"][current_branch]["replies"].push_back({
					"reply": "edit text",
					"next": "0",
					"exit": "false"
				})
	_pop_nodes(current_dialogue, current_branch, true, 0)
	
func _reply_clicked(a):
	pass	
	
# WTF
func _button_hover(a, b, c):
	if a == null:
		get_node("main/variables").hide()
	else:
		get_node("main/variables").show()
		variables(c)

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


func _on_setToActive_pressed():

	var dir = Directory.new()
	
	global.save_file("res://data/editor/cache/", current_dialogue, session_cache)
	global.charData[session_cache.name.to_lower()]["dialogue"]["default"]["path"] = "res://data/editor/cache/" + current_dialogue
#	global.charData[session_cache.name.to_lower()]["dialogue"]["default"]["branch"] = current_branch
	

func _on_resetActiveDialogue_pressed():
	global.charData["ellie"]["dialogue"]["default"]["branch"] = "1"

#	expands dialogue tree. Wonky righ now, so v
func _on_expand_pressed():

	$dialogue_picker.set_position(Vector2(($dialogue_picker.get_position() + Vector2(150, 0))))
	$nodes.set_position(Vector2($nodes.get_position() + Vector2(150, 0)))
	$main.set_position(Vector2($main.get_position() + Vector2(150, 0)))
	$"main/expand".set_position(Vector2($"main/expand".get_position() + Vector2(150, 0)))
	
func variables(id):

	print(id)
	if $"main/variables/container":
		$"main/variables/container".queue_free()
		$"main/variables/container".set_name("DELETED")
		
	# TODO: 0 is hardcoded, so always gets keys of first reply. Need to make dynamic
	var numsize = session_cache["dialogue"][current_branch]["replies"][id].size()
	var keys = session_cache["dialogue"][current_branch]["replies"][id].keys()
	var values = session_cache["dialogue"][current_branch]["replies"][id].values()
	
	_create_new_UI_element("container", VBoxContainer, $"main/variables", 0, 0, 0, 0)	

	for i in numsize:
		if keys[i] != "reply":
			_create_new_UI_element("variable" + str(i), Label, $"main/variables/container", 0, 0, 0, 0)
			get_node("main/variables/container/variable" + str(i)).set_text(str(keys[i]) + " : " + str(values[i]))
