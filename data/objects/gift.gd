extends StaticBody

signal look_at(a,b)
signal highlight(a)
signal dialogue(a,b,c)

#will just carry character name, all other data will be moved to charData in global.gd
var identity 	: String 		= "giftbox"
var branch 		: String 		= ""
var gender		: Array			= []
var pickupable	: bool			= true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_trigger_mouse_entered():
	global.hover = {
		"id"	: "gift",
		"type"	: "object",
		"position" : get_global_transform().origin
	}
	if global.itemInHand == "" and global.blocking_ui!=true:
		global.change_cursor("hand")
		emit_signal("highlight", identity)
		if global.proximity(global.gameRoot.get_node("player").get_global_transform().origin,
					self.get_global_transform().origin,
					4):
			global.change_cursor("hand")
	elif global.blocking_ui!=true:
			emit_signal("highlight", "Use " + global.itemInHand + " with " + identity + "?")


func _on_trigger_mouse_exited():
	if global.itemInHand == "" and global.blocking_ui != true and global.dialogue_running != true:
		global.change_cursor("default")
	global.hover = {
		"id"	: null,
		"type"	: null,
		"position"	: null
	}
	emit_signal("highlight", "")
	emit_signal("look_at", "")


func _on_trigger_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and global.blocking_ui!=true:
		if event.is_pressed():
			if global.itemInHand == "":	
				if global.proximity(global.gameRoot.get_node("player").get_global_transform().origin,
									self.get_global_transform().origin,
									2):
					pickup()
#				else:
#					global.balloon("Need to get closer.", global.gameRoot.get_node("player"), "player")
			else:
				global.balloon("That won´t work.", global.gameRoot.get_node("player"), "player")
		
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			emit_signal("look_at", "It´s a giftbox.")
			
func pickup():
	global.inventoryData["gifts"]["gift"] = {
		"id" : "gift",
		"description" : "a gift"
	}

	global.remove_from_scene("objects", "gift")
	global.change_cursor("default")
	global.update_points(2)
	global.playerMoving = false
	
	var picked_up = get_node("../../ui/new_item")
	picked_up.show()
	picked_up.get_node("item_text").text = identity
	picked_up.get_node("materialize").interpolate_property(
		picked_up, 
		"modulate", 
		Color(1,1,1,0), 
		Color(1,1,1,1), 1, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT)
	picked_up.get_node("materialize").start()
	
	#todo: not working, try signal instead
	get_node("../../soundfx").set_stream(load("res:/data/sounds/new_item.wav"))
	get_node("../../soundfx").play()

