extends Area2D

var inventory_node = preload("res://data/ui/nodes/inventory_node.tscn")

var x_start = 155
var y_start = 260
var y_offset = 0
var x_offset = 0

func _ready():
	pop_inventory()

func pop_inventory():
	var items = global.inventoryData["items"]

	for item in $container/panel/inventory_items.get_children():
		item.queue_free()
		item.set_name("deleted")
	
	#if you have something stored in inventoryData, populate the inventory pane
	if !items.empty():
		var count = 0
		
		for key in items.keys():
			if count != 0 and count % 5 == 0:
				y_offset += 64
				x_offset += 350
				
			var image = load("res://data/ui/graphics/inv_" + items[key].id + ".png")
			
			var node = inventory_node.instance()
			node.id = items[key].id
			node.set_name(items[key].id)
			node.set_position(Vector2(x_start + count * 64 - x_offset, y_start + y_offset))
			node.connect("change_cursor", $"/root/game/ui", "item_in_hand")
			node.connect("item_id", self, "_item_id")
			$container/panel/inventory_items.add_child(node)
			$container/panel/inventory_items.get_node(items[key].id).set_texture(image)
			
			count += 1

func _item_id(id):
		get_node("container/panel/item").text = id
	

