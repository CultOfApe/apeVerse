extends Label

signal reply_selected(a)
signal reply_mouseover(a,b)

var num_reply : int = 0 #this is set to another number in world.gd, when the label is instanced, to identify the reply for when you pick it later

func _ready():
	pass

func _on_reply_mouse_entered():
	add_color_override("font_color", Color(1,0,1))
	emit_signal("reply_mouseover",true ,num_reply)

func _on_reply_mouse_exited():
	add_color_override("font_color", Color(1,1,1))
	emit_signal("reply_mouseover",false ,num_reply)

func _on_reply_gui_input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_LEFT and ev.is_pressed():
			emit_signal("reply_selected",num_reply)
		else:
			pass
