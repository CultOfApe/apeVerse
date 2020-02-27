extends Panel

signal on_click(a, b, c)
signal on_hover(a, b)
signal on_edit(a)

var id 			: String = ""
var dialogue	: String	= "" 
var branch 		: String = ""
var reply		: String	= ""
var modifier 	: int = 1

func _ready():
	pass

func _on_Label_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				# TODO: emit this signal to edit text. $Edit.show - What variables do I need to emit?
				if event.control:
					$"Label/Edit".show()
					print("edit text")
#					emit_signal("on_edit", id, true)
				else:
					emit_signal("on_click", branch, true, modifier)

func _on_Label_mouse_entered():
	pass

func _on_Label_mouse_exited():
	pass # Replace with function body.

# key input to finalize and save edit. Enter, or CTRl+Enter
func _on_Edit_gui_input(event):
	if event.is_pressed():
		if event.control and event.scancode == KEY_ENTER:
			$"Label".set_text($"Label/Edit".get_text())
			$"Label/Edit".hide()
			$"indicator".show()
			print("close edit")
