extends Sprite

var id = null
var hovering = false

signal change_cursor(a, b)

func _ready():
	var ui_node = get_node("/root/world/ui")
#	ui_node.connect("change_cursor", self, "item_in_hand")

func _process(delta):
	pass

func _input(event):
	if hovering == true:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					global.itemInHand = id
					emit_signal("change_cursor", "hand", "res://data/ui/graphics/inv_" + id + ".png")
			
func _on_area_mouse_entered():
	hovering = true

func _on_area_mouse_exited():
	hovering = false
