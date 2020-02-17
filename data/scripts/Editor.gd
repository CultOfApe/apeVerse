extends Control

onready var clickButton : Object  = load("res://data/asset scenes/node_click_button.tscn") #PackedScene
onready var editorNode : Object  = load("res://data/UI/Editor_panel_label.tscn") #PackedScene
onready var SCREENSIZE 	: Vector2 = get_viewport().get_visible_rect().size

var editorChain : Array # Array containing reference to all current nodes in dialogue tree, hierarchically

var JSONfiles : Array

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("ui_editor") and !global.editor_running:
		_setup_editor()
#		_temp_setup("ellie_default")
								
	if event.is_action_pressed("ui_down") and global.editor_running:
		_kill_editor()
				
func _setup_editor():
	global.editor_running = true
		
	global.files = []
	var folder : Array = global.list_files_in_directory("res://data/dialogue/")
		
	for item in folder:
		JSONfiles.push_back(item)

	_create_new_UI_element("json_files", VBoxContainer, self, 0, 0, 0, 0)	
	
	for i in range(JSONfiles.size()):
		_create_instanced_UI_element("json_files_b" + str(i), clickButton, $"json_files", 0, 0, 0, 0, null)

	for i in range(JSONfiles.size()):
		get_node("json_files/json_files_b" + str(i)).id = JSONfiles[i]
		get_node("json_files/json_files_b" + str(i)).set_text(JSONfiles[i])
		get_node("json_files/json_files_b" + str(i)).connect("button_clicked",self,"_button_clicked",[], CONNECT_ONESHOT)
		get_node("json_files/json_files_b" + str(i)).connect("button_hover",self,"_button_hover")	
		
func _kill_editor():
		for x in self.get_children():
			x.set_name("DELETED") #to make sure node doesn´t cause issues before being deleted
			x.queue_free()
		global.editor_running = false

func _create_new_UI_element(id, type, parent, xsize, ysize, xpos, ypos): # add variable to cancel instancing, or instance outside of func(?)
	var node = type.new()
	node.set_name(id)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("button_on_click",self,"_button_on_click")
	if parent != null:
		parent.add_child(node) 
	
func _create_instanced_UI_element(name, obj, parent, xsize, ysize, xpos, ypos, margin): # add variable to cancel instancing, or instance outside of func(?)
	var node = obj.instance()
	node.set_name(name)
	node.set_size(Vector2(xsize, ysize))
	node.set_position(Vector2(xpos, ypos))
	node.connect("button_on_click",self,"_button_on_click")
	if parent != null:
		parent.add_child(node) 
	
func _button_clicked(id):
	var node = global.load_json("res://data/dialogue/" + id)
	
	_create_instanced_UI_element("dialogueNode", editorNode, self, 400, 300, SCREENSIZE.x/2 - 200, SCREENSIZE.y/2 - 150, 10)		
#	get_node("dialogueNode/Label").id(id)
	get_node("dialogueNode/Label").set_size(Vector2(380,280))
	get_node("dialogueNode/Label").set_position(Vector2(10,10))
	get_node("dialogueNode/Label").set_text("This is dialogue!")
	
	var numReplies = node["dialogue"]["1"]["replies"][0].size()
	var offset = (numReplies * 100 + numReplies * 25 - 25) / 2
	
	for i in numReplies:
		_create_instanced_UI_element("replyNode" + str(i), editorNode, self, 300, 100, SCREENSIZE.x/2 + 300, SCREENSIZE.y/2 + (i * 125) - offset, 10)
		get_node("replyNode" + str(i) + "/Label").set_size(Vector2(280,80))
		get_node("replyNode" + str(i) + "/Label").set_position(Vector2(10,10))
		get_node("replyNode" + str(i) + "/Label").set_text(node["dialogue"]["1"]["replies"][i]["reply"]) #crashes if one reply only. Rethink.

	get_node("dialogueNode/Label").set_text(node["dialogue"]["1"]["speech"][0])
	
func _button_hover():
	print("Button hover!")
