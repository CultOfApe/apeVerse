extends Label

signal dialogueClicked

func _ready():
	pass

#TODO: input signal when space pressed, to skip dialogue. Here or in dialogue.gd?
#TODO: clicking ESC should quit dialogue window

func _on_dialogue_gui_input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_LEFT:
			if ev.is_pressed():
				emit_signal("dialogueClicked")
				
func _input(event):
	if event.is_action_pressed("Skip") and global.dialogue_waiting == true:
		emit_signal("dialogueClicked")
