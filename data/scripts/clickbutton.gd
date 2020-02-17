extends Label

signal button_clicked(a)
signal button_hover(a)

var id : String 

func _ready():
	pass

func _on_button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			emit_signal("button_clicked", id)
		else:
			pass

func _on_button_mouse_entered():
	add_color_override("font_color", Color(1,0,1))
	emit_signal("button_hover",true)


func _on_button_mouse_exited():
	add_color_override("font_color", Color(1,1,1))
	emit_signal("button_hover",false)
