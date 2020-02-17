extends Label

signal dialogueClicked

func _ready():
	pass

func _on_dialogue_gui_input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_LEFT:
			if ev.is_pressed():
				emit_signal("dialogueClicked")
