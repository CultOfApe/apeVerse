extends Node

signal timer_end

var isLookingAt 	: bool = false

var day 			: int = 2
var time 			: int = 0
var month 			: int = 6
var dayOfMonth 		: int = 1

var tNode 		

onready var descriptionLabel 	: Label = $"ui/descriptionLabel"
onready var bubble 				: Label = $"ui/bubble"

onready var screenBlur 			: TextureRect = $"effects/blurfx"
onready var materialize 		: Tween = $"effects/materialize"
onready var dissolve 			: Tween = $"effects/dissolve"

onready var viewsize = get_viewport().get_visible_rect().size

func _ready():
	global.change_cursor("default")
	
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
	for object in get_node("objects").get_children():
		object.connect("highlight", self, "_highlight")
		
	for object in get_node("npcs").get_children():
		object.connect("look_at", self, "_look_at")
	for object in get_node("npcs").get_children():
		object.connect("dialogue", get_node("dialogue"), "_talk_to")
	for object in get_node("npcs").get_children():
		object.connect("highlight", self, "_highlight")

func _process(delta):
	if global.gameType == "3D" and global.playerMoving:
		bubble.set_position($Camera.unproject_position((get_node("player").translation) + Vector3(0,2.5,0)) - Vector2(30,0))

func change_location(location):
	global.scene = location
	global.load_scene(location)
	connect_stuff()

func _look_at(text):
	global.balloon(text, get_tree().get_root().get_node("game").get_node("player"), "player")
	
func _highlight(text):
	descriptionLabel.set_text(text)

func dissolve():
	dissolve.interpolate_property(tNode, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	dissolve.start()
	isLookingAt = false

# when materialize tween is finished,wait 1.5 seconds, and then run dissolve tween on same object
func _on_materialize_tween_completed(object, key):
	_wait(1.5)
	tNode = global.playerBubble

func _on_materialize2_tween_completed(object, key):
	_wait(1.5)
	tNode = global.npcBubble
	
func _wait( seconds ):
	#create and run timer only once, then run function dissolve()
	_create_timer(self, seconds, true, "dissolve")
	yield(self,"timer_end")

func _create_timer(object_target, float_wait_time, bool_is_oneshot, string_function):
	var timer := Timer.new()
	timer.set_one_shot(bool_is_oneshot)
	timer.set_timer_process_mode(0)
	timer.set_wait_time(float_wait_time)
	timer.connect("timeout", object_target, string_function)
	self.add_child(timer)
	timer.start()



