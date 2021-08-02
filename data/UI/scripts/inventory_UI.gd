extends Area2D

var tab = null

var inventoryData
var tab_tab = 1

var inventory_node = preload("res://data/ui/nodes/inventory_node.tscn")

func _ready():
#	inventoryData = global.inventoryData.tools
#	TODO: needs to be run every time the inventory UI is toggled, to update removed and added items for the open tab
	pop_inventory()

func pop_inventory():
	var items = global.inventoryData["items"]

	for item in $inventory_items.get_children():
		item.queue_free()
		item.set_name("deleted")

	var row = 0
	var rtrn = 0
	
	#if you have something stored in inventoryData, populate the inventory pane
	if !items.empty():
		var count = items.size()
		var i = 0
		
		for key in items.keys():
			if i == 5 or i == 10 or i == 15 or i == 20 or i == 25 or i == 30:
				row += 64
				rtrn += 350
			var node = inventory_node.instance()
			node.id = items[key].id
			node.set_name(items[key].id)
			node.set_position(Vector2(155 + i*70 - rtrn, 260 + row))
			node.connect("change_cursor", get_node("/root/game/ui"), "item_in_hand")
			node.connect("item_id", self, "_item_id")
			$inventory_items.add_child(node)
			var image = load("res://data/ui/graphics/inv_" + items[key].id + ".png")
			$inventory_items.get_node(items[key].id).set_texture(image)
			i += 1
					

	else:
		pass

func _item_id(id):
		get_node("container/panel/item").text = id
	
	
#Which tab is clicked? Populate inventory accordingly.
func _input(event):
	pass

