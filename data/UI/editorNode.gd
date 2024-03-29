extends Panel

signal on_click(a, b, c)
signal on_hover(a, b)
signal on_edit(a)

var id 			: String = ""
var nodetype	: String = ""
var dialogue	: Dictionary
var branch 		: String = ""
var reply		: int
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
					$"Label/Edit".grab_click_focus()
				else:
					if nodetype == "reply":
						emit_signal("on_click", branch, true, modifier)

func _on_Label_mouse_entered():
	if nodetype == "reply":
		$"Label".add_color_override("font_color", Color(1,10,10))

func _on_Label_mouse_exited():
	if nodetype == "reply":
		$"Label".add_color_override("font_color", Color(1,1,1))

# key input to finalize and save edit. Enter, or CTRl+Enter
func _on_Edit_gui_input(event):
	if event.is_pressed():
		if event.control and event.scancode == KEY_ENTER:
			$"Label".set_text($"Label/Edit".get_text())
			$"Label/Edit".hide()
			$"indicator".show()
			$"save".show()
			print("close edit")
			
func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				print("adding!")
				$"Panel/Label".show()
				$"Label/Edit".show()
				$add.hide()

func _on_add_pressed():
	$"Label".show()
	$"Label/Edit".show()
	$add.hide()

# TODO: Doesn´t actually save anything yet
func _on_save_pressed():
	if $save.get_text() == "SAVE":
		$"indicator".set_text("SAVED")
		$"save".set_text("RESET")
		print(global.editorData[dialogue["file"]])
		if nodetype == "reply":
			global.editorData[dialogue["file"]]["cache"]["dialogue"][branch]["replies"][reply]["reply"]= $"Label".get_text()
		elif nodetype == "dialogue":
			global.editorData[dialogue["file"]]["cache"]["dialogue"][branch]["speech"] = $"Label".get_text()
	else:
		pass
#		$"indicator".hide()
#		$"save".hide()
