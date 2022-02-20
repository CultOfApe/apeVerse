extends Panel

signal on_click(a, b, c)
signal on_hover(a, b, c)
signal on_edit(a)

var id 			: String = ""
var nodetype	: String = ""
var dialogue	: String = ""
var branch 		: String = ""
var next		: String = ""
var exit		: bool	 = false
var reply		: int
var modifier 	: int = 1
var avatar 		= null
var active		: bool

func _ready():
	active = true

func _on_Label_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed() and !exit:
				# TODO: emit this signal to edit text. $Edit.show - What variables do I need to emit?
				if event.control:
					$"advanced".show()
					$"Label/Edit".show()
					$"Label/Edit".grab_click_focus()
				else:
					if nodetype == "reply":
#						print("branch: " + branch)
#						print("next: " + next)
						emit_signal("on_click", next, true, modifier)


func _on_Label_mouse_entered():
	if nodetype == "reply" and !exit:
		$"Label".add_color_override("font_color", Color(1,10,10))
		emit_signal("on_hover", dialogue, branch, reply)

func _on_Label_mouse_exited():
	if nodetype == "reply":
		$"Label".add_color_override("font_color", Color(1,1,1))
		emit_signal("on_hover", null, null, null)

# key input to finalize and save edit. Enter, or CTRl+Enter
func _on_Edit_gui_input(event):
	if event.is_pressed():
		if event.control and event.scancode == KEY_ENTER:
			$"Label".set_text($"Label/Edit".get_text())
			$"Label/Edit".hide()
			$"advanced".hide()
			
func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				$"Panel/Label".show()
				$"Label/Edit".show()
				$add.hide()

func _on_add_pressed():
	$"Label".show()
	$"Label/Edit".show()
	$add.hide()
# 	global.editorData[dialogue["file"]]["cache"]["dialogue"][branch]["replies"].push_back(
#		{
#			"reply": "",
#			"next": "",
#			"exit": "" 
#		}
#	)

