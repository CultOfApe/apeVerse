extends Label

signal dialogue_clicked

func _ready():
	pass
				
func _input(event):
	if event.is_action_pressed("Skip") and global.dialogue_waiting == true:
		emit_signal("dialogue_clicked")
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				emit_signal("dialogue_clicked")
