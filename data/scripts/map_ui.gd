extends Area2D

#the below should be loaded in global.gd from gamedata json
onready var map01 = $"map01/Sprite"
onready var map02 = $"map02/Sprite"
onready var map03 = $"map03/Sprite"

onready var label = $label

#onready var sceneCol = get_tree().get_root().get_node("Node").get_node("scene").get_node("col")

signal location_chosen(a)

func _ready():
	pass

func _on_map01_mouse_entered():
	if global.currentLocation != "schoolyard":
		map01.show()
		label.set_text("School yard")
		label.set_position($map01.get_position() + Vector2(-30, 45))
		global.blocking_ui = true

func _on_map01_mouse_exited():
	map01.hide()
	label.set_text("")
	
func _on_map01_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if global.currentLocation != "schoolyard":
			global.playerMoving = false
			emit_signal("location_chosen", "schoolyard")

func _on_map02_mouse_entered():
	if global.currentLocation != "schoolhall":
		map02.show()
		label.set_text("School hall")
		label.set_position($map02.get_position() + Vector2(-30, 45))
		global.blocking_ui = true

func _on_map02_mouse_exited():
	map02.hide()
	label.set_text("")

func _on_map02_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if global.currentLocation != "schoolhall":
			global.playerMoving = false
			emit_signal("location_chosen", "schoolhall")

func _on_map03_mouse_entered():
	if global.currentLocation != "myroom":
		map03.show()
		label.set_text("My room")
		label.set_position($map03.get_position() + Vector2(-30, 45))
		global.blocking_ui = true

func _on_map03_mouse_exited():
	map03.hide()
	label.set_text("")

func _on_map03_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if global.currentLocation != "myroom":
			global.playerMoving = false
			emit_signal("location_chosen", "myroom")
