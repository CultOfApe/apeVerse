extends Sprite

var id = null

signal change_cursor(a, b)
signal item_id(a)

func _ready():
	var ui_node = get_node("/root/world/ui")

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				global.itemInHand = id
				global.floor_collision.disabled = true
				global.blocking_ui = true
				emit_signal("change_cursor", "hand", "res://data/ui/graphics/inv_" + id + ".png")

func _on_area_mouse_entered():
	emit_signal("item_id", id)

func _on_area_mouse_exited():
	emit_signal("item_id", "")
