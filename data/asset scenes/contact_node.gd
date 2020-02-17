extends Panel

signal call(a)

var id : String

func _ready():
	pass # Replace with function body.

func _on_call_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				emit_signal("call", id)
