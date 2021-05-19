extends Control

onready var screen_blur 	:= $"../effects/blurfx"
onready var click_node := load("res://data/editor/assets/node_click_button.tscn") #PackedScene
onready var editor_node 	:= load("res://data/editor/assets/Editor_panel_label.tscn") #PackedScene
onready var SCREENSIZE 	:= get_viewport().get_visible_rect().size

var current_dialogue		: String
var current_path			: String
var current_branch		: String
var previous_branch = null
var reverse = false
var previous_session = false

var node_chain 	:= {} # Array containing reference to all current nodes in dialogue tree, hierarchically
var nodes_origin

var JSON_files 	: Array

func _ready():
	pass

func _input(event):
	#show or hide editor
	if event.is_action_pressed("ui_editor") and !global.editor:
		self.show()
		_setup_editor()						
	if event.is_action_pressed("ui_down") and global.editor:
		_kill_editor()
		screen_blur.modulate = Color(1, 1, 1, 0)
	
func _setup_editor():
	global.blocking_ui = true
	global.editor = true
	global.files = []
	screen_blur.modulate = Color(1, 1, 1, 1)
	
	#if a previous session has been initiated, remember and open with previous nodes visible
	if previous_session == false:
		for node in get_tree().get_nodes_in_group("editor_main"):
			node.hide()
	
	var folder : Array = global.list_files_in_directory("res://data/dialogue/json")
	for item in folder:
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
		for x in self.get_children():
			x.set_name("DELETED") #to make sure node doesn´t cause issues before being deleted
			x.queue_free()
			
		global.blocking_ui = false
		global.editor = false

func _create_new_UI_element(id, type, parent, xsize, ysize, xpos, ypos): # add variable to cancel instancing, or instance outside of func(?)
	var node = type.new()
	node.set_name(id)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("on_click",self,"_on_node_click")
	if parent != null:
		parent.add_child(node) 
	
func _create_instanced_UI_element(id, obj, parent, xsize, ysize, xpos, ypos, margin): # add variable to cancel instancing, or instance outside of func(?)
	var node = obj.instance()
	node.set_name(id)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("on_click",self,"_on_node_click")
	if parent != null:
		parent.add_child(node) 

# TODO: If existing nodes, spawn new nodes at x + 1080, and then move over $"nodes" x -1080
func _pop_nodes(id, branch, reset, modifier):
	
	previous_session == true
	$avatar.show()
	$avatar.connect("avatar_clicked",self,"_avatar_clicked")
	_setup_avatar_selector()
	
	$json_files.set_position(Vector2(($json_files.get_position() - Vector2(150, 0))))
	
	$main/topMenu.show()
	$main/options.show()
	$expand.show()
	
	if reset:
		if $"nodes":
			$"nodes".queue_free()
			$"nodes".set_name("DELETED")
			
	if !$"nodes":
		var nodeContainer = Position2D.new()
		nodeContainer.set_name("nodes")
		self.add_child(nodeContainer)	
		
	if !node_chain == {}:
		nodes_origin = $nodes.get_position()
	
	current_dialogue = id
	
	# TODO: need a separate nodeChainCache to store multiple dialogue trees currentSession
	if !node_chain.has(current_dialogue):
		node_chain = {current_dialogue : [branch],
					"active" : 0}
					
	# FIX: this shouldn´t be run if we traverse backwards in the nodetree. Do we need another flag? :P
	elif node_chain[current_dialogue].back() != branch: #and reverse != true:
		node_chain[current_dialogue].push_back(branch)
		
	node_chain["active"] += modifier
		
	if node_chain[current_dialogue].size() > 1:
		previous_branch = str(node_chain[current_dialogue][(node_chain.active) - 1])
	
	reverse = false
	current_branch 	= str(node_chain[current_dialogue][node_chain.active])
	
	var node = global.load_json("res://data/dialogue/json/" + id)
	
	var root = Node2D.new()
	root.set_name(branch)
	$"nodes".add_child(root)

#	TODO: PREPCODE. Button!
	if node["dialogue"][node_chain[current_dialogue][(node_chain.active) - 1]].has("avatar"):
		get_node("avatar/avatar").queue_free()
		get_node("avatar/avatar").set_name("DELETED")
		var avatar = load("res://data/npcs/ellie_talkanim.tscn")
		avatar = avatar.instance()
		avatar.set_name("avatar")
		avatar.set_position(Vector2(75, 100)) #BAD: hardcoded
		$avatar.add_child(avatar)
		$avatar.id = "res://data/npcs/ellie_talkanim.tscn"
	
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
#	$avatar.set_animation(node_chain[current_dialogue][node_chain.active]) 
#	["dialogue"][global.charData[npc]["dialogue"][type]["branch"]]

	var replies_size = node["dialogue"][branch]["replies"].size()

	var offset = ((replies_size + 1) * 100 + (replies_size + 1) * 25 - 25) / 2
	
	if node_chain.has(current_dialogue): #and node_chain[current_dialogue].size() != 1:

#		print("----------------------------")
#		print("DEBUG Editor.gd")
#		print("----------------------------")
#		print(" ")	
#		print(" " + String(node_chain))
#		print(" This chain has " + str(node_chain[current_dialogue].size()) + " nodes and the current node has index no. " + str(node_chain[current_dialogue].size() -1))
#		print(" current node has value: " + node_chain[current_dialogue][node_chain[current_dialogue].size() - 1])
#		print(" and has " + String(node["dialogue"][node_chain[current_dialogue][(node_chain.active) - 1]]["replies"].size()) + " replies")
#		print(" ")	
#		print("----------------------------")
#		print("DEBUG end")
#		print("----------------------------")
#		print(" ")	
	
		if node_chain.active != 0: # calc by active-1 instead
#			print("previous node has value: " + previous_branch)
			var previous_replies_size = node["dialogue"][node_chain[current_dialogue][(node_chain.active) - 1]]["replies"].size()
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

	for i in (replies_size + 1):
		if i < replies_size:
			var next = node["dialogue"][branch]["replies"][i]["next"]
		
			_create_instanced_UI_element(str(i), editor_node, get_node("nodes/" + branch), 300, 100, SCREENSIZE.x/2 + 300, SCREENSIZE.y/2 + (i * 125) - offset, 10)
			get_node("nodes/" + branch + "/" + str(i)).dialogue = {"file": id, "branch": current_branch, "reply": i}
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
			_create_instanced_UI_element(str(i), editor_node, get_node("nodes/" + branch), 300, 100, SCREENSIZE.x/2 + 300, SCREENSIZE.y/2 + (i * 125) - offset, 10)
			get_node("nodes/" + branch + "/" + str(i) + "/Label").set_size(Vector2(280,80))
			get_node("nodes/" + branch + "/" + str(i) + "/Label").set_position(Vector2(10,10))
			get_node("nodes/" + branch + "/" + str(i)).nodetype = "add"
			get_node("nodes/" + branch + "/" + str(i)).id = "add"
			get_node("nodes/" + branch + "/" + str(i) + "/Label/Edit").set_size(Vector2(280,80))
			get_node("nodes/" + branch + "/" + str(i) + "/Label/Edit").set_text("")
			get_node("nodes/" + branch + "/" + str(i) + "/Label").hide()
			get_node("nodes/" + branch + "/" + str(i) + "/add").show()
		
#		print(get_node("nodes/" + branch + "/" + str(i)).dialogue)
		
		#save editor session to cache, only save to file if explicitly stated
		global.editorData[current_dialogue] = node_chain
		if !global.editorData[current_dialogue].has("cache"):
			global.editorData[current_dialogue]["cache"] = global.load_json("res://data/dialogue/" + id)
			
#func _setup_avatar_selector():
#	var avatar_thumb = load("res://data/editor/assets/button_avatar.tscn")
#
#	for i in global.list_files_in_directory("res://data/graphics/avatars"):
#		var thumb = avatar_thumb.instance()
#		thumb.set_name(i)
#		thumb.set_button_icon(load("res://data/graphics/avatars/" + i))
#		self.add_child(thumb)
#
#	print(self.get_child_count()) #don´t use self, new subdirectory

#	when clicking on reply node
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

func _setup_avatar_selector():
	# REFACTOR: extract the first texture from a sprite node scene, avoiding having to display every texture frame
	# NOTE : This is an experimental mess right now, just playing around with things
	$select.clear()
	$select.set_as_toplevel(true)
	$select.set_size(Vector2(550, 750))
	$select.set_position(Vector2(SCREENSIZE.x / 2 - 275, SCREENSIZE.y / 2 - 375))
	
	var iterate = 0
	var avatar_thumb = load("res://data/editor/assets/button_avatar.tscn")
	for i in global.list_files_in_directory("res://data/editor/graphics/avatars"):
		$select.add_icon_item(load("res://data/editor/graphics/avatars/" + i), true)
		$select.set_item_metadata (iterate, i)
		iterate += 1 
	
	#WIP: This is how all icons will be added in the future
	var face = load("res://data/npcs/ellie_talkanim.tscn")
	face = face.instance()
	for i in face.get_sprite_frames().get_frame_count("default"):
		$select.add_icon_item(face.get_sprite_frames().get_frame("default", i), true)	
		$select.set_item_metadata (iterate, "ellie_talkanim.tscn")
		iterate += 1 
	
	# WIP: if image, add to button, if tscn change the avatar node to this scene
	# for now. In the future this will only accept animatedsprites.
	
	iterate = 0

func _on_select_item_selected(index):
#	WIP: click on item, change avatar
	if "tscn" in $select.get_item_metadata(index):
		get_node("avatar/avatar").queue_free()
		get_node("avatar/avatar").set_name("DELETED")
		var avatar = load("res://data/npcs/" + ($select.get_item_metadata(index)))
		avatar = avatar.instance()
		avatar.set_name("avatar")
		avatar.set_position(Vector2(75, 100)) #BAD: hardcoded
		$avatar.add_child(avatar)
		$avatar.id = "index"
#		get_node("avatar/avatar").set_frame(2)
	if "png" in $select.get_item_metadata(index):
		get_node("avatar/Button").set_button_icon(load("res://data/editor/graphics/avatars/" + $select.get_item_metadata(index)))
		
	$select.hide()
	
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

#TODO: references dictionary local to editorNode.gd. Needs solution.
func _on_setToActive_pressed():
	pass
#	var dir = Directory.new()
#	dir.copy("res://files/sprite_image.tex", "res://sprite_image.tex")
#	global.charData[npc]["dialogue"][type]["branch"]]["replies"]
#	global.editorData[dialogue["file"]]["cache"]

func _on_saveSession_pressed():
	var file = File.new()
	file.open("res://data/editor/session.save", File.WRITE)
	file.store_line(to_json(node_chain))
	file.close()

#	expands dialogue tree. Wonky righ now, so TODO
func _on_expand_pressed():

	$json_files.set_position(Vector2(($json_files.get_position() + Vector2(150, 0))))
	$nodes.set_position(Vector2($nodes.get_position() + Vector2(150, 0)))
	$main.set_position(Vector2($main.get_position() + Vector2(150, 0)))
	$expand.hide()
	
func _avatar_clicked():
	$select.show()
