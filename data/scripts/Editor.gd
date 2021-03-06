extends Control

onready var screenBlur 	: TextureRect	= $"../effects/blurfx"
onready var clickButton : Object  		= load("res://data/asset scenes/node_click_button.tscn") #PackedScene
onready var editorNode 	: Object  		= load("res://data/UI/Editor_panel_label.tscn") #PackedScene
onready var SCREENSIZE 	: Vector2 		= get_viewport().get_visible_rect().size

var currentDialogue
var currentPath
var currentBranch
var previousBranch = null
var reverse = false

var nodeChain = {}# Array containing reference to all current nodes in dialogue tree, hierarchically

var JSONfiles 			: Array

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("ui_editor") and !global.editor:
		self.show()
		_setup_editor()
								
	if event.is_action_pressed("ui_down") and global.editor:
		_kill_editor()
		screenBlur.modulate = Color(1, 1, 1, 0)

#TODO: Editor should remember last open session		
func _setup_editor():
	
	for node in get_tree().get_nodes_in_group("editor_advanced"):
		node.hide()
	$keymap.hide()
	$topMenu.hide()
	$options.hide()
	
	
	screenBlur.modulate = Color(1, 1, 1, 1)
	
	global.editor = true
		
	global.files = []
	var folder : Array = global.list_files_in_directory("res://data/dialogue/")
		
	for item in folder:
		JSONfiles.push_back(item)

	_create_new_UI_element("json_files", VBoxContainer, self, 0, 0, 0, 0)	
	
	for i in range(JSONfiles.size()):
		_create_instanced_UI_element("json_files_b" + str(i), clickButton, $"json_files", 0, 0, 0, 0, null)

	for i in range(JSONfiles.size()):
		get_node("json_files/json_files_b" + str(i)).id = JSONfiles[i]
		get_node("json_files/json_files_b" + str(i)).branch = "1"
		get_node("json_files/json_files_b" + str(i)).set_text(JSONfiles[i])
		get_node("json_files/json_files_b" + str(i)).connect("on_click",self,"_pop_nodes",[], CONNECT_ONESHOT)
		get_node("json_files/json_files_b" + str(i)).connect("button_hover",self,"_button_hover")	
		
func _kill_editor():
		for x in self.get_children():
			x.set_name("DELETED") #to make sure node doesn´t cause issues before being deleted
			x.queue_free()
		global.editor = false

func _create_new_UI_element(id, type, parent, xsize, ysize, xpos, ypos): # add variable to cancel instancing, or instance outside of func(?)
	var node = type.new()
	node.set_name(id)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("on_click",self,"_on_node_click")
	if parent != null:
		parent.add_child(node) 
	
func _create_instanced_UI_element(name, obj, parent, xsize, ysize, xpos, ypos, margin): # add variable to cancel instancing, or instance outside of func(?)
	var node = obj.instance()
	node.set_name(name)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("on_click",self,"_on_node_click")
#	print(node.name)
	if parent != null:
		parent.add_child(node) 

# TODO: If existing nodes, spawn new nodes at x + 1080, and then move over $"nodes" x -1080
func _pop_nodes(id, branch, reset, modifier):
	
	$topMenu.show()
	$options.show()
	
	if reset:
		if $"nodes":
			$"nodes".queue_free()
			$"nodes".set_name("DELETED")
			
	if !$"nodes":
		var nodeContainer = Position2D.new()
		nodeContainer.set_name("nodes")
		self.add_child(nodeContainer)	
	
	currentDialogue = id
	
	# TODO: need a separate nodeChainCache to store multiple dialogue trees currentSession
	if !nodeChain.has(currentDialogue):
		nodeChain = {currentDialogue : [branch],
					"active" : 0}
					
	# FIX: this shouldn´t be run if we traverse backwards in the nodetree. Do we need another flag? :P
	elif nodeChain[currentDialogue].back() != branch: #and reverse != true:
		nodeChain[currentDialogue].push_back(branch)
		
	nodeChain["active"] += modifier
		
	if nodeChain[currentDialogue].size() > 1:
		previousBranch = str(nodeChain[currentDialogue][(nodeChain.active) - 1])
	
	reverse = false
	currentBranch 	= str(nodeChain[currentDialogue][nodeChain.active])
	
	var node = global.load_json("res://data/dialogue/" + id)
	
	var root = Node2D.new()
	root.set_name(branch)
	$"nodes".add_child(root)
	
	_create_instanced_UI_element("dialogue", editorNode, get_node("nodes/" + branch), 400, 300, SCREENSIZE.x/2 - 200, SCREENSIZE.y/2 - 150, 10)		
#	get_node("dialogueNode/Label").id(id)
	get_node("nodes/" + branch + "/dialogue/Label").set_size(Vector2(380,280))
	get_node("nodes/" + branch + "/dialogue/Label").set_position(Vector2(10,10))
	get_node("nodes/" + branch + "/dialogue/Label").set_text(node["dialogue"][branch]["speech"][0])
	get_node("nodes/" + branch + "/dialogue").nodetype = "dialogue"
	get_node("nodes/" + branch + "/dialogue").id = branch
	
	get_node("nodes/" + branch + "/dialogue/Label/Edit").set_size(Vector2(380,280))
	get_node("nodes/" + branch + "/dialogue/Label/Edit").set_text(node["dialogue"][branch]["speech"][0])
	get_node("nodes/" + branch + "/dialogue/Label/Edit").grab_focus()

	var numReplies = node["dialogue"][branch]["replies"].size()

	var offset = ((numReplies + 1) * 100 + (numReplies + 1) * 25 - 25) / 2
	
	if nodeChain.has(currentDialogue): #and nodeChain[currentDialogue].size() != 1:
		
#		print(nodeChain)
#		print("This chain has " + str(nodeChain[currentDialogue].size()) + " nodes and the current node has index no. " + str(nodeChain[currentDialogue].size() -1))
#		print("current node has value: " + nodeChain[currentDialogue][nodeChain[currentDialogue].size() - 1])
#		print("and has " + node["dialogue"][nodeChain[currentDialogue]["replies"].size()] + " replies")
		
		if nodeChain.active != 0: # calc by active-1 instead
			print("previous node has value: " + previousBranch)
			var prevnumReplies = node["dialogue"][nodeChain[currentDialogue][(nodeChain.active) - 1]]["replies"].size()
			var prevoffset = (prevnumReplies * 100 + prevnumReplies * 25 - 25) / 2
	
			for i in prevnumReplies:
				var oldroot = Node2D.new()
				oldroot.set_name(previousBranch)
				$"nodes".add_child(oldroot)
				var next = node["dialogue"][previousBranch]["replies"][i]["next"]
	#			print(next)
				
				# This is not working as well as I thought. While it displays previous replies, clicking around sometimes produces unexpected results...
				# need variable for last reply, make so when you click it, it takes you back, whereas the other replies don´t
				_create_instanced_UI_element(str(i), editorNode, get_node("nodes/" + previousBranch), 300, 100, SCREENSIZE.x/2 -600, SCREENSIZE.y/2 + (i * 125) - prevoffset, 10)
				
				get_node("nodes/" + previousBranch + "/" + str(i)).dialogue = {"file": id, "branch": previousBranch, "reply": i}
				if next != currentBranch:
					get_node("nodes/" + previousBranch + "/" + str(i)).branch = next
				else:
					get_node("nodes/" + previousBranch + "/" + str(i)).branch = previousBranch
					get_node("nodes/" + previousBranch + "/" + str(i) + "/Label").add_color_override("font_color", Color(1,0,0))
				get_node("nodes/" + previousBranch + "/" + str(i)).reply = ""
				get_node("nodes/" + previousBranch + "/" + str(i)).modifier = -1
				get_node("nodes/" + previousBranch + "/" + str(i) + "/Label").set_size(Vector2(280,80))
				get_node("nodes/" + previousBranch + "/" + str(i) + "/Label").set_position(Vector2(10,10))
				get_node("nodes/" + previousBranch + "/" + str(i) + "/Label").set_text(node["dialogue"][previousBranch]["replies"][i]["reply"]) #crashes if one reply only. Rethink
				get_node("nodes/" + previousBranch + "/" + str(i)).nodetype = "reply"
				get_node("nodes/" + previousBranch + "/" + str(i)).id = str(i)
				get_node("nodes/" + previousBranch + "/" + str(i) + "/Label/Edit").set_size(Vector2(280,80))
				get_node("nodes/" + previousBranch + "/" + str(i) + "/Label/Edit").set_text(node["dialogue"][previousBranch]["replies"][i]["reply"])
				get_node("nodes/" + previousBranch + "/" + str(i) + "/Label/Edit").grab_click_focus()

	for i in (numReplies + 1):
		if i < numReplies:
			var next = node["dialogue"][branch]["replies"][i]["next"]
		
			_create_instanced_UI_element(str(i), editorNode, get_node("nodes/" + branch), 300, 100, SCREENSIZE.x/2 + 300, SCREENSIZE.y/2 + (i * 125) - offset, 10)
			get_node("nodes/" + branch + "/" + str(i)).dialogue = {"file": id, "branch": currentBranch, "reply": i}
			get_node("nodes/" + branch + "/" + str(i)).branch = next
			get_node("nodes/" + branch + "/" + str(i)).reply = ""
			get_node("nodes/" + branch + "/" + str(i)).modifier = 1
			get_node("nodes/" + branch + "/" + str(i) + "/Label").set_size(Vector2(280,80))
			get_node("nodes/" + branch + "/" + str(i) + "/Label").set_position(Vector2(10,10))
			get_node("nodes/" + branch + "/" + str(i) + "/Label").set_text(node["dialogue"][branch]["replies"][i]["reply"])
			get_node("nodes/" + branch + "/" + str(i)).nodetype = "reply"
			get_node("nodes/" + branch + "/" + str(i)).id = str(i)
			get_node("nodes/" + branch + "/" + str(i) + "/Label/Edit").set_size(Vector2(280,80))
			get_node("nodes/" + branch + "/" + str(i) + "/Label/Edit").set_text(node["dialogue"][branch]["replies"][i]["reply"])
		else:
			_create_instanced_UI_element(str(i), editorNode, get_node("nodes/" + branch), 300, 100, SCREENSIZE.x/2 + 300, SCREENSIZE.y/2 + (i * 125) - offset, 10)
			get_node("nodes/" + branch + "/" + str(i) + "/Label").set_size(Vector2(280,80))
			get_node("nodes/" + branch + "/" + str(i) + "/Label").set_position(Vector2(10,10))
			get_node("nodes/" + branch + "/" + str(i)).nodetype = "add"
			get_node("nodes/" + branch + "/" + str(i)).id = "add"
			get_node("nodes/" + branch + "/" + str(i) + "/Label/Edit").set_size(Vector2(280,80))
			get_node("nodes/" + branch + "/" + str(i) + "/Label/Edit").set_text("")
			get_node("nodes/" + branch + "/" + str(i) + "/Label").hide()
			get_node("nodes/" + branch + "/" + str(i) + "/add").show()
		
		print(get_node("nodes/" + branch + "/" + str(i)).dialogue)
		
		#save editor session to cache, only save to file if explicitly stated
		global.editorData[currentDialogue] = nodeChain
		if !global.editorData[currentDialogue].has("cache"):
			global.editorData[currentDialogue]["cache"] = global.load_json("res://data/dialogue/" + id)

func _on_node_click(branch, null, modifier):
	#TODO: shouldn´t be called if node has same id as current branch
	print("-------------------------------")
	if modifier == -1:
		reverse = true
	else:
		reverse = false
	if branch == currentBranch:
		modifier = 0
	_pop_nodes(currentDialogue, branch, true, modifier)
	
func _reply_clicked(a):
	pass	
	
func _button_hover():
	pass


func _on_help_toggled(button_pressed):
	if button_pressed:
		$keymap.show()
	else:
		$keymap.hide()


func _on_advanced_toggled(button_pressed):
	if button_pressed:
		for node in get_tree().get_nodes_in_group("editor_advanced"):
			node.show()
	else:
		for node in get_tree().get_nodes_in_group("editor_advanced"):
			node.hide()
	
