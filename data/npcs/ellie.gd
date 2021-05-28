extends StaticBody

signal look_at(a,b)
signal highlight(a)
signal dialogue(a,b,c)

#will just carry character name, all other data will be moved to charData in global.gd
var identity 	: String 		= "ellie"
var branch 		: String 		= "1"
var gender		: Array			= ["she", "her"]

var inventory 	: Array = [
	"clothes",
	"glasses",
	"bag"
]

# handles response to gifts
var gifts : Dictionary	= {
	"default" : {
		"response" 	: "...",
		"value" 	: null,
		"event" 	: null,
		"cutscene" 	: null
	},
	"rose" : {
		"response" 	: "Thank you!",
		"value" 	: null,
		"event" 	: null,
		"cutscene" 	: null,
		"points"	: 2
	}
}


func _ready():
	$"Olga_animated/Armature/AnimationPlayer".play()
#	$Character/AnimationPlayer.autoplay = "Idle-loop"
	$"Olga_animated/Armature/AnimationPlayer".get_animation("idle").set_loop(true)
		
			
# handles response to gifts
func itemGiven(id):
	if gifts.has(id):
		if gifts[id]["response"]:
			global.playerMoving = false
			global.balloon(gifts[id]["response"], self, "npc")
		if gifts[id]["value"]:
			pass
		if gifts[id]["event"]:
			pass


func _on_npc_trigger_mouse_enter():
	global.hover = {
		"id"	: "ellie",
		"type"	: "npc"
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
		"type"	: null
	}
	emit_signal("highlight", "")
	emit_signal("look_at", "")

func _on_npc_trigger_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !global.blocking_ui:
		if event.is_pressed():
			if global.itemInHand == "":	
				emit_signal("dialogue", identity, self.get_transform().origin, "default")

			else:
				var keys := global.inventoryData.keys()
				global.change_cursor("default")
				itemGiven(global.itemInHand)
				#global.inventoryData["junk"].remove(0)
				global.update_points(gifts[global.itemInHand]["points"])
				global.itemInHand = ""
		
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			emit_signal("look_at", "That´s Ellie. She´s cute!")
