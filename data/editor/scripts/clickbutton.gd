extends Label

signal on_click(a, b, c)
signal on_hover(a, b)

var id : String 
var branch : String 

func _ready():
	pass

func _on_button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			emit_signal("on_click", id, branch, true, 0)
		else:
			pass

func _on_button_mouse_entered():
	add_color_override("font_color", Color(1,0,1))
	emit_signal("on_hover",true, id)


func _on_button_mouse_exited():
	add_color_override("font_color", Color(1,1,1))
	emit_signal("on_hover",false, id)
