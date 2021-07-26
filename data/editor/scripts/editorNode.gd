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
var avatar 		= null

func _ready():
	pass

func _on_Label_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				# TODO: emit this signal to edit text. $Edit.show - What variables do I need to emit?
				if event.control:
					$"advanced".show()
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

# TODO: Doesn´t actually save anything yet, will crash when saving a dialogue node :P
func _on_save_pressed():
	if $save.get_text() == "SAVE":
		$"indicator".set_text("SAVED")
		$"save".set_text("RESET")

		# print(global.editorData) # {ellie.json:{active:1, cache:Null, ellie.json:[1, 2]}}
	
		if nodetype == "reply":
			global.editorData[dialogue["file"]]["cache"]["dialogue"][branch]["replies"][reply]["reply"]= $"Label".get_text()
		elif nodetype == "dialogue":
			global.editorData[dialogue["file"]]["cache"]["dialogue"][branch]["speech"] = $"Label".get_text()
			
		var dir = Directory.new()
		dir.copy("res://data/dialogue/" + dialogue["file"], "res://data/editor/backup/" + dialogue["file"] + ".bak")
		
#		var file = File.new()
#		file.open("res://data/saves/" + id + ".save", File.WRITE)
#		file.store_line(to_json(saveData))
#		file.close()
		# TODO: next write new data to dialogue file and redraw nodes
	else:
		pass
#		$"indicator".hide()
#		$"save".hide()
