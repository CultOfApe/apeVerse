extends Node

signal timer_end

#flags/states
#var isMoving 		: bool = false
#var isRotating 		: bool = false
#var noMoveOnClick 	: bool = false
#var dialogueRunning : bool = false
var isLookingAt 	: bool = false

var day 			: int = 2
var time 			: int = 0
var month 			: int = 6
var dayOfMonth 		: int = 1

#var thoughts_showing: bool = false

#var sceneData : Dictionary

onready var descriptionLabel 	: Node2D = $"ui/descriptionLabel"
onready var thought_bubble 		: Node2D = $"ui/thoughtBubble"

onready var screenBlur 			: Node2D = $"effects/blurfx"
onready var materialize 		: Node2D = $"ui/thoughtBubble/materialize"
onready var dissolve 			: Node2D = $"ui/thoughtBubble/dissolve"

onready var viewsize = get_viewport().get_visible_rect().size

func _ready():
	var cursor = load("res://data/graphics/cursor_default.png")
	Input.set_custom_mouse_cursor(cursor)
	
	set_process(true)
	set_process_input(true)
	
	#This should be set in global already? Probably a leftover...	
	$"ui/dateLabel".set_text(global.gameData.time[time] + ", " + global.weekday)	
	
	global.scene = "schoolyard"
	#Why? WHY does the below affect rotation of the NPC if I remove it?!
#	sceneData = global.load_json("res://data/locations/location_schoolyard.json")
	global.load_scene("schoolyard")

	connect_stuff()
	
func connect_stuff():
	for object in get_node("objects").get_children():
		object.connect("look_at", self, "_look_at")
	for object in get_node("npcs").get_children():
		object.connect("look_at", self, "_look_at")
	for object in get_node("npcs").get_children():
		object.connect("dialogue", get_node("dialogue"), "_talk_to")
	for object in get_node("npcs").get_children():
		object.connect("highlight", self, "_highlight")

func _process(delta):
	#This should only be called when the thought bubbl is actually showing?
		if global.gameType == "3D":
			thought_bubble.set_position($Camera.unproject_position((get_node("player").translation) + Vector3(0,2.5,0)) - Vector2(30,0))

func change_location(location):
	global.scene = location
	global.load_scene(location)
	connect_stuff()
	#issue with map scene changing is in ui_exit, sets global.blocking_ui = false
	#find alternative solution

func _input(event):
	pass

func _look_at(text):
	pass

func thought_bubble(text):
	if text != "": # and isLookingAt == false:
		thought_bubble.show()
		materialize.interpolate_property(thought_bubble, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		materialize.start()
		isLookingAt = true

	thought_bubble.add_color_override("font_color", Color(0,0,0,1))
	thought_bubble.set_text(text)
	
func _highlight(text):
#	descriptionLabel.set_position($Camera.unproject_position($player.translation) - Vector2(60,230))
	descriptionLabel.set_text(text)

#Are the below functions leftovers, or still used? Investigate by commenting out (all of them)
func _on_tween_tween_completed(object, key):
	pass # replace with function body

func _on_materialize_tween_completed(object, key):
	_wait(2)

func _wait( seconds ):
	self._create_timer(self, seconds, true, "dissolve")
	yield(self,"timer_end")

func dissolve():
	dissolve.interpolate_property(thought_bubble, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	dissolve.start()
	isLookingAt = false

func _create_timer(object_target, float_wait_time, bool_is_oneshot, string_function):
	# KidsCanCode suggested yield(get_tree().create_timer(2.0), 'timeout')
	# will try that version later, but for now this works great
	var timer = Timer.new()
	timer.set_one_shot(bool_is_oneshot)
	timer.set_timer_process_mode(0)
	timer.set_wait_time(float_wait_time)
	timer.connect("timeout", object_target, string_function)
	self.add_child(timer)
	timer.start()
