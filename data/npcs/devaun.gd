extends StaticBody

signal look_at(a)
signal highlight(a)
signal dialogue(a,b,c)

#will just carry character name, all other data will be moved to charData in global.gd
var identity 	: String 	= "devaun"
var branch 		: String 	= "1"
var gender		: Array		= ["he", "his"]

var inventory 	: Array 	= [
	"clothes",
	"glasses",
	"bag"
]

func _ready():
	$Character/AnimationPlayer.play()
#	$Character/AnimationPlayer.autoplay = "Idle-loop"
	$Character/AnimationPlayer.get_animation("Run").set_loop(true)
		
func _on_npc_trigger_mouse_enter():
	if global.itemInHand == "" and global.blocking_ui!=true:
		global.change_cursor("talk")
	if global.itemInHand == "" and global.blocking_ui!=true:
		emit_signal("highlight", identity)
	else:
		if global.blocking_ui!=true:
			emit_signal("highlight", "Give " + global.itemInHand + " to " + identity + "?")

func _on_npc_trigger_mouse_exit():
	if global.itemInHand == "" and global.blocking_ui!=true:
		global.change_cursor("default")
	emit_signal("highlight", "")
	emit_signal("look_at", "")

func _on_npc_trigger_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and global.blocking_ui!=true:
		if event.is_pressed():
			if global.itemInHand == "":	
				global.blocking_ui = true
				global.sceneCol.disabled = true
				emit_signal("dialogue", identity, self.get_transform().origin, "default")
			else:
				var keys = global.inventoryData.keys()
				global.change_cursor("default")
				global.inventoryData["junk"].remove(0)
		
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			emit_signal("look_at", "It´s Devaun.")
