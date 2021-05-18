extends Panel

func _ready():
	init_nodes()
	
func init_nodes():
	if global.saveData.empty():
		for i in range(6):
			if i == 0:
				global.saveData["page" + String(global.save_page)] = {		
					"save1" : {
						"id" : null,
						"thumb" : "save_add",
						"data" : {}
					}
				}
			else:
				global.saveData["page" + String(global.save_page)]["save" + String(i + 1)] = {		
						"id" : null,
						"thumb" : null,
						"data" : {}
					}
					
		# TODO: should only run when settings menu is called 
		pop_nodes(global.save_page)

	
func pop_nodes(page):
	for save in range(6):
		var save_node = get_node("savegames/save" + str(save+1))
		var save_name = "save" + String(save + 1)
#		print(savename)
		
		if global.saveData["page" + String(global.save_page)]:
#			print("has save page!")
			if global.saveData["page" + String(global.save_page)].has(save_name):
				if global.saveData["page" + String(global.save_page)][save_name]["thumb"] == "save_add":
#					print("is save_add!")
					var image = load("res://data/graphics/saves/save_add.png")
					save_node.set_texture(image)
				elif global.saveData["page" + String(global.save_page)][save_name]["thumb"] != null:	
#					print("is thumb!")
					var image = load("user://" + save_name + ".png")
					save_node.set_texture(image)
				elif global.saveData["page" + String(global.save_page)][save_name]["thumb"] == null:	
					pass
#					print("is null!")

func save_template(id, thumb, data):
	var save_info = {			
				"id" : id,
				"thumb" : thumb,
				"data" : data
			}
	return save_info
			
func save_to_slot(id, save_page):
	global.capture.resize(500,281,1)
	var save_name = "save" + str(id)
	
	# if next save slot is on next page, increment page number
	if id < 6:
		global.saveData["page" + String(global.save_page)]["save" + str(id+1)] = save_template(save_name, "save_add", [])
	elif id == 6:
		global.saveData["page" + String(global.save_page + 1)]["save1"] = save_template(save_name, "save_add", [])
	
	var dir = Directory.new()
	if dir.file_exists("user://" + save_name + ".png"):
		dir.remove("user://" + save_name + ".png")
	global.capture.save_png("user://" + save_name + ".png")
	
	var texture = ImageTexture.new()
	var save_node = get_node("savegames/save" + str(id))
	texture.create_from_image(global.capture)
	save_node.set_texture(texture)

	global.saveData["page" + String(global.save_page)][save_name].thumb = save_name

	global._save_game(save_name, save_page) # This whole script needs to be refactored, but at least save functionality skeleton taking shape
	
	pop_nodes(global.save_page)


func add_to_savedata(page):
		
	# for number of saveslots
	for i in range(6):
		if i == 0:
			global.saveData[page] = {		
				"save1" : {
					"id" : null,
					"thumb" : "save_add",
					"data" : {}
				}
			}
		else:
			global.saveData[page]["save" + String(i + 1)] = {		
					"id" : null,
					"thumb" : null,
					"data" : {}
	
			}

	for i in global.saveData.size():
		if global.saveData.has("page" + String(i + 1)):
			get_node("savegames/page" + String(i + 1)).show()
			
		
func _on_save1_mouse_entered():
	save_fx($savegames/save1, Color(1,1,1,1))

func _on_save1_mouse_exited():
	save_fx($savegames/save1, Color(1,1,1,0.5))

func _on_save1_input_event(viewport, event, shape_idx):
	# compare global.save_page and savenode 1 to global.saveData
#	if get_node("savegames/save1").texture.get_path() == "res://data/graphics/saves/save_add.png":
	if global.saveData["page" + String(global.save_page)]["save1"].thumb == "save_add":
#	if get_node("savegames/save1").texture:
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT:
					if event.is_pressed():
						save_to_slot(1, global.save_page)

func _on_save2_mouse_entered():
	save_fx($savegames/save2, Color(1,1,1,1))

func _on_save2_mouse_exited():
	save_fx($savegames/save2, Color(1,1,1,0.5))
	
func _on_save2_input_event(viewport, event, shape_idx):
	if global.saveData["page" + String(global.save_page)]["save2"].thumb =="save_add":
#	if get_node("savegames/save1").texture:
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT:
					if event.is_pressed():
						save_to_slot(2, global.save_page)


func _on_save3_mouse_entered():
	save_fx($savegames/save3, Color(1,1,1,1))

func _on_save3_mouse_exited():
	save_fx($savegames/save3, Color(1,1,1,0.5))

func _on_save3_input_event(viewport, event, shape_idx):
	if global.saveData["page" + String(global.save_page)]["save3"].thumb == "save_add":
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT:
					if event.is_pressed():
						save_to_slot(3, global.save_page)


func _on_save4_mouse_entered():
	save_fx($savegames/save4, Color(1,1,1,1))
	
func _on_save4_mouse_exited():
	save_fx($savegames/save4, Color(1,1,1,0.5))

func _on_save4_input_event(viewport, event, shape_idx):
	if global.saveData["page" + String(global.save_page)]["save4"].thumb == "save_add":
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					save_to_slot(4, global.save_page)


func _on_save5_mouse_entered():
	save_fx($savegames/save5, Color(1,1,1,1))

func _on_save5_mouse_exited():
	save_fx($savegames/save5, Color(1,1,1,0.5))

func _on_save5_input_event(viewport, event, shape_idx):
	if global.saveData["page" + String(global.save_page)]["save5"].thumb == "save_add":
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					save_to_slot(5, global.save_page)


func _on_save6_mouse_entered():
	save_fx($savegames/save6, Color(1,1,1,1))

func _on_save6_mouse_exited():
	save_fx($savegames/save6, Color(1,1,1,0.5))

func _on_save6_input_event(viewport, event, shape_idx):
	if global.saveData["page" + String(global.save_page)]["save6"].thumb == "save_add":
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					add_to_savedata("page" + String(global.save_page +1))
					save_to_slot(6, global.save_page)


func _on_load_mouse_entered():
	pass # replace with function body

func _on_load_mouse_exited():
	pass # replace with function body

func _on_load_input_event():
	pass # replace with function body


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
	if global.save_page != 1:
		$savegames/page1/label_background.show()

func _on_page1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.save_page = 1
				pop_nodes("page1")
				flush_paginator()
				get_node("savegames/page1/label_background").hide()

func _on_page2_mouse_entered():
	$savegames/page2/label_background.hide()

func _on_page2_mouse_exited():
	if global.save_page != 2:
		$savegames/page2/label_background.show()

func _on_page2_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.save_page = 2
				pop_nodes("page2")
				flush_paginator()
				get_node("savegames/page2/label_background").hide()

func _on_page3_mouse_entered():
	$savegames/page3/label_background.hide()

func _on_page3_mouse_exited():
	if global.save_page != 3:
		$savegames/page3/label_background.show()

func _on_page3_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.save_page = 3
				pop_nodes("page3")
				flush_paginator()
				get_node("savegames/page2/label_background").hide()


func _on_page4_mouse_entered():
	$savegames/page4/label_background.hide()

func _on_page4_mouse_exited():
	if global.save_page != 4:
		$savegames/page4/label_background.show()

func _on_page4_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.save_page = 4
				pop_nodes("page4")
				flush_paginator()
				get_node("savegames/page4/label_background").hide()


func _on_page5_mouse_entered():
	$savegames/page5/label_background.hide()

func _on_page5_mouse_exited():
	if global.save_page != 5:
		$savegames/page5/label_background.show()

func _on_page5_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.save_page = 5
				pop_nodes("page5")
				flush_paginator()
				get_node("savegames/page5/label_background").hide()


func _on_page6_mouse_entered():
	$savegames/page6/label_background.hide()

func _on_page6_mouse_exited():
	if global.save_page != 6:
		$savegames/page6/label_background.show()

func _on_page6_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.save_page = 6
				pop_nodes("page6")
				flush_paginator()
				get_node("savegames/page6/label_background").hide()


func _on_page7_mouse_entered():
	$savegames/page7/label_background.hide()

func _on_page7_mouse_exited():
	if global.save_page != 7:
		$savegames/page7/label_background.show()

func _on_page7_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.save_page = 7
				pop_nodes("page7")
				flush_paginator()
				get_node("savegames/page7/label_background").hide()


func _on_page8_mouse_entered():
	$savegames/page8/label_background.hide()

func _on_page8_mouse_exited():
	if global.save_page != 8:
		$savegames/page8/label_background.show()

func _on_page8_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.save_page = 8
				pop_nodes("page8")
				flush_paginator()
				get_node("savegames/page8/label_background").hide()
				
func flush_paginator():
	for node in range(8):
		get_node("savegames").get_child(node).show()

func save_fx(save, opacity):
	$fx.interpolate_property(save, "modulate", save.modulate, opacity, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$fx.start()
