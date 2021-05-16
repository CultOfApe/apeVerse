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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_trigger_mouse_entered():
	global.hover = {
		"id"	: "giftbox",
		"type"	: "object"
	}
	if global.itemInHand == "" and global.blocking_ui!=true:
		var cursor : Object = load("res://data/graphics/cursor_look.png")
		Input.set_custom_mouse_cursor(cursor)
		emit_signal("highlight", identity)
	elif global.blocking_ui!=true:
			emit_signal("highlight", "Use " + global.itemInHand + " with " + identity + "?")


func _on_trigger_mouse_exited():
	if global.itemInHand == "" and global.blocking_ui != true and global.dialogue_running != true:
		var cursor := load("res://data/graphics/cursor_default.png")
		Input.set_custom_mouse_cursor(cursor)
	emit_signal("highlight", "")
	emit_signal("look_at", "")


func _on_trigger_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and global.blocking_ui!=true:
		if event.is_pressed():
			if global.itemInHand == "":	
				pass

			else:
				pass
		
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			emit_signal("look_at", "It´s a giftbox.")
