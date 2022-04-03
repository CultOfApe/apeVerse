extends Node

signal timer_end

#var isLookingAt 	: bool = false

var day 			: int = 2
var time 			: int = 0
var month 			: int = 6
var dayOfMonth 		: int = 1

var tNode 		

onready var descriptionLabel 	: Label = $"ui/descriptionLabel"

onready var screenBlur 			: TextureRect = $"effects/blurfx"

onready var viewsize = get_viewport().get_visible_rect().size

func _ready():
	global.change_cursor("default")
	
	#This should be set in global already? Probably a leftover...	
	$"ui/dateLabel".set_text(global.gameData.time[time] + ", " + global.weekday)	
	
	global.scene = "schoolyard"
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
	pass

func change_location(location):
	global.scene = location
	global.load_scene(location)
	connect_stuff()

func _look_at(text):
	global.balloon(text, get_tree().get_root().get_node("game").get_node("player"), "player")
	
func _highlight(text):
	descriptionLabel.set_text(text)
