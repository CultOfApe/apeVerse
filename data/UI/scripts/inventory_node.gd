extends Sprite

var id = null

signal change_cursor(a, b)

func _ready():
	var ui_node = get_node("/root/world/ui")

func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				global.itemInHand = id
				global.sceneCol.disabled = true
				global.blocking_ui = true
				emit_signal("change_cursor", "hand", "res://data/ui/graphics/inv_" + id + ".png")
