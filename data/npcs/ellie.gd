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
	
func _process(delta):
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
		else:
			var node = reaction.instance()
			node.set_name("reaction")
			$ui_anchor.add_child(node) 
		
			$"tweens/tween_in".interpolate_property(
				$reaction, 
				"modulate", 
				Color(1,1,1,0), 
				Color(1,1,1,1), 
				1, 
				Tween.TRANS_LINEAR, 
				Tween.EASE_IN_OUT)

			$"tweens/tween_in".start()
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

func _on_npc_trigger_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !global.blocking_ui:
		if event.is_pressed():
			if global.itemInHand == "":	
				emit_signal("dialogue", identity, self.get_transform().origin, "default")
			else:
				pass
		
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			emit_signal("look_at", "That´s Ellie. She´s cute!")

func dissolve():
	$"tweens/tween_out".interpolate_property($"ui_anchor", "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$"tweens/tween_out".start()
	global.lookingAt = false

func _on_tween_in_tween_completed(object, key):
	global.wait_and_execute(2, "dissolve", self)

func _on_tween_out_tween_completed(object, key):
	pass # Replace with function body.
