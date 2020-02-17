extends StaticBody

signal look_at(a)
signal highlight(a)
signal dialogue(a,b,c)

#will just carry character name, all other data will be moved to charData in global.gd
var identity 	: String = "devaun"
var branch 		: String = "1"

var inventory 	: Array = [
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
		var cursor = load("res://data/graphics/cursor_talk.png")
		Input.set_custom_mouse_cursor(cursor)
	if global.itemInHand == "" and global.blocking_ui!=true:
		emit_signal("highlight", identity)
	else:
		if global.blocking_ui!=true:
			emit_signal("highlight", "Give " + global.itemInHand + " to " + identity + "?")

func _on_npc_trigger_mouse_exit():
	if global.itemInHand == "" and global.blocking_ui!=true:
		var cursor = load("res://data/graphics/cursor_default.png")
		Input.set_custom_mouse_cursor(cursor)
	emit_signal("highlight", "")
#	emit_signal("look_at", "")

func _on_npc_trigger_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and global.blocking_ui!=true:
		if event.is_pressed():
			if global.itemInHand == "":	
				global.blocking_ui = true
				global.sceneCol.disabled = true
				emit_signal("dialogue", identity, self.get_transform().origin, "default")
			else:
				var keys = global.inventoryData.keys()
				var cursor = load("res://data/graphics/cursor_default.png")
				Input.set_custom_mouse_cursor(cursor)
				global.inventoryData["junk"].remove(0)
				
				#TODO: this is hardcoded, and should be handled by script
#				if global.itemInHand == "rose":
#					var heart = get_tree().get_root().get_node("world").get_node("effects").get_node("cuttlefish")
#					var texture = load("res://data/graphics/UI/heart.png")
#					var heartTween = get_tree().get_root().get_node("world").get_node("effects").get_node("tween")
#					heart.set_texture(texture)
#					heart.set_position(Vector2(650, 270))
#					heart.show()
#					heartTween.interpolate_property(heart, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#					heartTween.interpolate_property(heart, "position", heart.position, Vector2(700, 170), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#
#				global.itemInHand = ""
				
# TODO: This turned into a mess... too make my life easier, assign a number to every item for simpler iteration of items. Will need to change 
# other code calling items oc...
#				for key in keys:
#					var keySize = global.inventoryData[key].size()
#					for size in range(keySize):
#						print(size)
#						if global.inventoryData[key][size]["id"] == "shoe":
#							global.inventoryData[key].remove(size)
#							print(key)
#							print("shoe")
#						else:
#							print("no shoe")
		
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			emit_signal("look_at", "It´s Devaun.")
