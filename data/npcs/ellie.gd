extends StaticBody

signal look_at(a,b)
signal highlight(a)
signal dialogue(a,b,c)
signal remove_item(id)

#will just carry character name, all other data will be moved to charData in global.gd
var identity 	: String 		= "ellie"
var branch 		: String 		= "1"
var gender		: Array			= ["she", "her"]

onready var reaction = load("res://data/ui/nodes/reaction.tscn")

#TODO: should be loaded from json
var inventory 	: Array = [
	"clothes",
	"glasses",
	"bag"
]

# handles response to gifts 
#TODO: should be loaded from json
var gifts : Dictionary	= {
	"default" : {
		"response" 	: "...",
		"value" 	: null,
		"event" 	: null,
		"cutscene" 	: null
	},
	"rose" : {
		"response" 	: null,
		"value" 	: null,
		"event" 	: null,
		"cutscene" 	: null,
		"points"	: 2
	},
	"gift" : {
		"response" 	: "Thank you!",
		"value" 	: null,
		"event" 	: null,
		"cutscene" 	: null,
		"points"	: 2
	}
}


func _ready():
	$"Olga_animated/Armature/AnimationPlayer".play()
	$"Olga_animated/Armature/AnimationPlayer".get_animation("idle").set_loop(true)
	self.connect("remove_item", $"/root/game/ui/schoolbag_ui", "pop_inventory")
	
func _process(_delta):
	#set anchor for UI elements slightly above head
	$ui_anchor.set_position(global.camera.unproject_position(self.translation - Vector3(0, -2.2, 0)))
		
# handles response to gifts
func itemGiven(id):
	global.playerMoving = false
	global.change_cursor("default")
	
	inventory.push_back(id)
	
	if gifts.has(id):
		global.inventoryData["items"].erase(id)
		global.update_points(gifts[id]["points"])
		emit_signal("remove_item")
		
	global.itemInHand = ""
				
	if gifts.has(id):
		if gifts[id]["response"] is String:
			global.active_character = identity
			global.balloon(gifts[id]["response"], self, "npc")
			print("1")
		else:
			print("2")
			var node = reaction.instance()
			node.set_name("reaction")
			node.modulate = Color(1,1,1,0)
			$ui_anchor.add_child(node) 
			
			var tween := create_tween()
			tween.tween_property($ui_anchor/reaction, "modulate", Color(1,1,1,1), 1)
			tween.tween_property($ui_anchor/reaction, "modulate", Color(1,1,1,0), 1)
			tween.tween_callback($ui_anchor/reaction, "queue_free")
			
#		if gifts[id]["value"]:
#			pass
#		if gifts[id]["event"]:
#			pass


func _on_npc_trigger_mouse_enter():
	global.hover = {
		"id"	: "ellie",
		"type"	: "npc",
		"position" : get_global_transform().origin
	}
	
	if global.itemInHand == "" and !global.blocking_ui:
		global.change_cursor("talk")
		emit_signal("highlight", identity)
	elif !global.blocking_ui:
			emit_signal("highlight", "Give " + global.itemInHand + " to " + identity + "?")
			
			
func _on_npc_trigger_mouse_exit():
	if global.itemInHand == "" and !global.blocking_ui and !global.dialogue_running:
		global.change_cursor("default")
	global.hover = {
		"id"	: null,
		"type"	: null,
		"position" : null
	}
	emit_signal("highlight", "")
	emit_signal("look_at", "")

func _on_npc_trigger_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !global.blocking_ui:
		if event.is_pressed():
			if global.itemInHand == "":	
				emit_signal("dialogue", identity, self.get_transform().origin, "default")
			else:
				pass
		
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			emit_signal("look_at", "That´s Ellie. She´s cute!")
