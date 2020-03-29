extends Panel

func _ready():
	pop_nodes("init", 0)

func _process(delta):
	pass
	
func pop_nodes(key, id):
	for save in range(global.saveData["page" + String(global.save_page)].size()):
		var save_node = get_node("savegames/save" + str(save+1))
		var tmp = "save" + str(save+1)

		if global.saveData["page1"].has(tmp):
			if global.saveData["page" + String(global.save_page)][tmp]["thumb"] == "save_add":
				var image = load("res://data/graphics/saves/save_add.png")
				save_node.set_texture(image)
		elif key == "init":
			var image = load("res://data/graphics/saves/save" + str(save+1) + ".png")
			save_node.set_texture(image)
			
func save_to_slot(id):
	var save_name = "save" + str(id)
	var tmpdict
	
	if get_node("savegames/" + save_name).texture.get_path() == "res://data/graphics/saves/save_add.png":
		if id < 6:
			tmpdict = {			
					"id" : save_name,
					"thumb" : "save_add",
					"data" : []
				}

		# add save icon to next node
		global.saveData["page" + String(global.save_page)]["save" + str(id+1)] = tmpdict

	global.capture.resize(500,281,1)
	var texture = ImageTexture.new()
	texture.create_from_image(global.capture)
	get_node("savegames/" + save_name).set_texture(texture)

	global.capture.save_png("res://data/graphics/saves/" + save_name + ".png")
	global.saveData["page" + String(global.save_page)][save_name].thumb = save_name
	if id < 6:
		pop_nodes("refresh", id)
	
	global._save_game(save_name) # This whole script needs to be refactored, but at least save functionality skeleton taking shape
			
func _on_save1_mouse_entered():
	save_fx($savegames/save1, Color(1,1,1,1))

func _on_save1_mouse_exited():
	save_fx($savegames/save1, Color(1,1,1,0.5))


func _on_save1_input_event(viewport, event, shape_idx):
	# if get_node("savegames/save1").texture.get_path() == "res://data/graphics/saves/save_add.png":
	if get_node("savegames/save1").texture:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					print("Save to slot 1")
					save_to_slot(1)

func _on_save2_mouse_entered():
	save_fx($savegames/save2, Color(1,1,1,1))

func _on_save2_mouse_exited():
	save_fx($savegames/save2, Color(1,1,1,0.5))
	
func _on_save2_input_event(viewport, event, shape_idx):
	if get_node("savegames/save2").texture:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					print("Save to slot 2")
					save_to_slot(2)


func _on_save3_mouse_entered():
	save_fx($savegames/save3, Color(1,1,1,1))

func _on_save3_mouse_exited():
	save_fx($savegames/save3, Color(1,1,1,0.5))

func _on_save3_input_event(viewport, event, shape_idx):
	if get_node("savegames/save3").texture:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					print("Save to slot 3")
					save_to_slot(3)


func _on_save4_mouse_entered():
	save_fx($savegames/save4, Color(1,1,1,1))
	
func _on_save4_mouse_exited():
	save_fx($savegames/save4, Color(1,1,1,0.5))

func _on_save4_input_event(viewport, event, shape_idx):
	if get_node("savegames/save4").texture:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					print("Save to slot 4")
					save_to_slot(4)


func _on_save5_mouse_entered():
	save_fx($savegames/save5, Color(1,1,1,1))

func _on_save5_mouse_exited():
	save_fx($savegames/save5, Color(1,1,1,0.5))

func _on_save5_input_event(viewport, event, shape_idx):
	if get_node("savegames/save5").texture:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					print("Save to slot 5")
					save_to_slot(5)


func _on_save6_mouse_entered():
	save_fx($savegames/save6, Color(1,1,1,1))

func _on_save6_mouse_exited():
	save_fx($savegames/save6, Color(1,1,1,0.5))

func _on_save6_input_event(viewport, event, shape_idx):
	if get_node("savegames/save6").texture:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					print("Save to slot 6")
					save_to_slot(6)


func _on_load_mouse_entered():
	pass # replace with function body

func _on_load_mouse_exited():
	pass # replace with function body

func _on_load_input_event():
	pass # replace with function body


func _on_save_mouse_entered():
	pass # replace with function body

func _on_save_mouse_exited():
	pass # replace with function body

func _on_save_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.capture.resize(640,400,1)
				global.capture.save_png("res://data/graphics/saves/screenshot - thumb.png")
				global._save_game("save1") # This whole script needs to be refactored, but at least save functionality skeleton taking shape
				print("Let´s save!")


func _on_exit_mouse_entered():
	pass # replace with function body

func _on_exit_mouse_exited():
	pass # replace with function body

func _on_exit_input_event():
	pass # replace with function body


func _on_patreon_mouse_entered():
	pass # replace with function body

func _on_patreon_mouse_exited():
	pass # replace with function body

func _on_patreon_input_event():
	pass # replace with function body


func _on_page1_mouse_entered():
	$savegames/page1/label_background.hide()

func _on_page1_mouse_exited():
	$savegames/page1/label_background.show()

func _on_page1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.capture.resize(640,400,1)
				global.capture.save_png("res://data/graphics/saves/screenshot - thumb.png")
				global._save_game("save1") # This whole script needs to be refactored, but at least save functionality skeleton taking shape
				print("Let´s save!")


func _on_page2_mouse_entered():
	$savegames/page2/label_background.hide()

func _on_page2_mouse_exited():
	$savegames/page2/label_background.show()

func _on_page2_input_event(viewport, event, shape_idx):
	pass # replace with function body


func _on_page3_mouse_entered():
	$savegames/page3/label_background.hide()

func _on_page3_mouse_exited():
	$savegames/page3/label_background.show()

func _on_page3_input_event(viewport, event, shape_idx):
	pass # replace with function body


#func _on_page4_mouse_entered():
#	$savegames/page4/label_background.hide()
#
#func _on_page4_mouse_exited():
#	$savegames/page4/label_background.show()
#
#func _on_page4_input_event():
#	pass # replace with function body
#
#
#func _on_page5_mouse_entered():
#	$savegames/page5/label_background.hide()
#
#func _on_page5_mouse_exited():
#	$savegames/page5/label_background.show()
#
#func _on_page5_input_event(viewport, event, shape_idx):
#	pass # replace with function body
#
#
#func _on_page6_mouse_entered():
#	$savegames/page6/label_background.hide()
#
#func _on_page6_mouse_exited():
#	$savegames/page6/label_background.show()
#
#func _on_page6_input_event(viewport, event, shape_idx):
#	pass # replace with function body
#
#
#func _on_page7_mouse_entered():
#	$savegames/page7/label_background.hide()
#
#func _on_page7_mouse_exited():
#	$savegames/page7/label_background.show()
#
#func _on_page7_input_event(viewport, event, shape_idx):
#	pass # replace with function body
#
#
#func _on_page8_mouse_entered():
#	$savegames/page8/label_background.hide()
#
#func _on_page8_mouse_exited():
#	$savegames/page8/label_background.show()
#
#func _on_page8_input_event(viewport, event, shape_idx):
#	pass # replace with function body

func save_fx(save, opacity):
	$fx.interpolate_property(save, "modulate", save.modulate, opacity, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$fx.start()
