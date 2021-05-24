extends Area2D

var tab = null

var inventoryData
var tab_tab = 1

var tabTexTools = preload("res://data/ui/graphics/inventory_tab_tools.png")
var tabTexGifts = preload("res://data/ui/graphics/inventory_tab_gifts.png")
var tabTexMisc = preload("res://data/ui/graphics/inventory_tab_misc.png")
var tabTexJunk = preload("res://data/ui/graphics/inventory_tab_junk.png")

var inventory_node = preload("res://data/ui/nodes/inventory_node.tscn")

func _ready():
#	inventoryData = global.inventoryData.tools
#	TODO: needs to be run every time the inventory UI is toggled, to update removed and added items for the open tab
	pop_inventory()

func pop_inventory():
	var category

	for item in $inventory_items.get_children():
		item.queue_free()
		item.set_name("deleted")
			
	if tab_tab == 1:
		category = "tools"
	elif tab_tab == 2:
		category = "gifts"
	elif tab_tab == 3:
		category = "misc"
	elif tab_tab == 4:
		category = "junk"

	var row = 0
	var rtrn = 0
	
	#if you have something stored in inventoryData, populate the inventory pane
	if !global.inventoryData[category].empty():
		var count = global.inventoryData[category].size()
		print("category: " + category)
		print("has " + String(count) + " keys")
		var i = 0
		for key in global.inventoryData[category].keys():
			if i == 5 or i == 10 or i == 15 or i == 20 or i == 25 or i == 30:
				row += 64
				rtrn += 350
			var node = inventory_node.instance()
			node.id = global.inventoryData[category][key].id
			node.set_name(global.inventoryData[category][key].id)
			node.set_position(Vector2(155 + i*70 - rtrn, 260 + row))
			node.connect("change_cursor", get_node("/root/game/ui"), "item_in_hand")
			$inventory_items.add_child(node)
			var image = load("res://data/ui/graphics/inv_" + global.inventoryData[category][key].id + ".png")
			$inventory_items.get_node(global.inventoryData[category][key].id).set_texture(image)
			i += 1
					

	else:
		pass

#Which tab is clicked? Populate inventory accordingly.
func _input(event):
	if tab != null:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			if tab == "tools":
				$container/panel/tabs/tex_tab.set_texture(tabTexTools)
				tab_tab = 1
				pop_inventory()
			elif tab == "gifts":
				$container/panel/tabs/tex_tab.set_texture(tabTexGifts)
				tab_tab = 2
				pop_inventory()
			elif tab == "misc":
				$container/panel/tabs/tex_tab.set_texture(tabTexMisc)
				tab_tab = 3
				pop_inventory()
			elif tab == "junk":
				$container/panel/tabs/tex_tab.set_texture(tabTexJunk)
				tab_tab = 4
				pop_inventory()

	#Tab through inventory categories instead of clicking on tab
	if event.is_action_pressed("ui_focus_next"):
		if tab_tab != 4:
			tab_tab += 1
		else:
			tab_tab = 1
			
		if tab_tab == 1:
			$container/panel/tabs/tex_tab.set_texture(tabTexTools)
		if tab_tab == 2:
			$container/panel/tabs/tex_tab.set_texture(tabTexGifts)
		if tab_tab == 3:
			$container/panel/tabs/tex_tab.set_texture(tabTexMisc)
		if tab_tab == 4:
			$container/panel/tabs/tex_tab.set_texture(tabTexJunk)
			
		pop_inventory()

func _on_tools_mouse_entered():
	$container/panel/debug.set_text("tools")
	tab = "tools"
	
func _on_tools_mouse_exited():
	tab = null

func _on_tools_input_event(body):
	pass # replace with function body

func _on_gifts_mouse_entered():
	$container/panel/debug.set_text("gifts")
	tab = "gifts"

func _on_gifts_mouse_exited():
	$container/panel/debug.set_text("")
	tab = null

func _on_gifts_input_event(camera, event, click_position, click_normal, shape_idx):
	pass

func _on_misc_mouse_entered():
	$container/panel/debug.set_text("misc")
	tab = "misc"

func _on_misc_mouse_exited():
	$container/panel/debug.set_text("")
	tab = null

func _on_junk_mouse_entered():
	$container/panel/debug.set_text("junk")
	tab = "junk"

func _on_junk_mouse_exited(area):
	$container/panel/debug.set_text("")
	tab = null

func _on_junk_input_event():
	pass # replace with function body
