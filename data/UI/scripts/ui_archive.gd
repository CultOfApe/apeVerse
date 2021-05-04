extends Panel

onready var phone = get_parent().get_parent()
onready var viewer = load("res://data/ui/nodes/image_viewer.tscn")

func _ready():
	pass

func icon_fx(photo, scale):
	$fx.interpolate_property (photo, "scale", photo.scale, scale, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$fx.start()

func _on_sprite1_mouse_entered():
	icon_fx($Sprite1, Vector2(1.1, 1.1))

func _on_sprite1_mouse_exited():
	icon_fx($Sprite1, Vector2(1, 1))

func _on_sprite1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.UI_lvl = 3
				var node = viewer.instance()
				node.set_name("viewer")
				node.add_to_group("UI_lvl_3")
				node.set_texture(load("res://data/UI/gallery/" + phone.gallery[global.gallery_page * 6 - 6]))
				node.set_global_position(Vector2(40, 120))
				$header.add_child(node)
				
func _on_sprite2_mouse_entered():
	icon_fx($Sprite2, Vector2(1.1, 1.1))

func _on_sprite2_mouse_exited():
	icon_fx($Sprite2, Vector2(1, 1))

func _on_sprite2_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.UI_lvl = 3
				var node = viewer.instance()
				node.set_name("viewer")
				node.add_to_group("UI_lvl_3")
				node.set_texture(load("res://data/UI/gallery/" + phone.gallery[global.gallery_page * 6 - 5]))
				node.set_global_position(Vector2(40, 120))
				$header.add_child(node)


func _on_sprite3_mouse_entered():
	icon_fx($Sprite3, Vector2(1.1, 1.1))

func _on_sprite3_mouse_exited():
	icon_fx($Sprite3, Vector2(1, 1))

func _on_sprite3_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.UI_lvl = 3
				var node = viewer.instance()
				node.set_name("viewer")
				node.add_to_group("UI_lvl_3")
				node.set_texture(load("res://data/UI/gallery/" + phone.gallery[global.gallery_page * 6 - 4]))
				node.set_global_position(Vector2(40, 120))
				$header.add_child(node)


func _on_sprite4_mouse_entered():
	icon_fx($Sprite4, Vector2(1.1, 1.1))

func _on_sprite4_mouse_exited():
	icon_fx($Sprite4, Vector2(1, 1))

func _on_sprite4_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.UI_lvl = 3
				var node = viewer.instance()
				node.set_name("viewer")
				node.add_to_group("UI_lvl_3")
				node.set_texture(load("res://data/UI/gallery/" + phone.gallery[global.gallery_page * 6 - 3]))
				node.set_global_position(Vector2(40, 120))
				$header.add_child(node)


func _on_sprite5_mouse_entered():
	icon_fx($Sprite5, Vector2(1.1, 1.1))

func _on_sprite5_mouse_exited():
	icon_fx($Sprite5, Vector2(1, 1))

func _on_sprite5_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.UI_lvl = 3
				var node = viewer.instance()
				node.set_name("viewer")
				node.add_to_group("UI_lvl_3")
				node.set_texture(load("res://data/UI/gallery/" + phone.gallery[global.gallery_page * 6 - 2]))
				node.set_global_position(Vector2(40, 120))
				$header.add_child(node)


func _on_sprite6_mouse_entered():
	icon_fx($Sprite6, Vector2(1.1, 1.1))

func _on_sprite6_mouse_exited():
	icon_fx($Sprite6, Vector2(1, 1))

func _on_sprite6_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.UI_lvl = 3
				var node = viewer.instance()
				node.set_name("viewer")
				node.add_to_group("UI_lvl_3")
				node.set_texture(load("res://data/UI/gallery/" + phone.gallery[global.gallery_page * 6 - 1]))
				node.set_global_position(Vector2(40, 120))
				$header.add_child(node)


func _on_page1_mouse_entered():
	$page1/highlight.show()

func _on_page1_mouse_exited():
	$page1/highlight.hide()


func _on_page2_mouse_entered():
	$page2/highlight.show()

func _on_page2_mouse_exited():
	$page2/highlight.hide()


func _on_page3_mouse_entered():
	$page3/highlight.show()

func _on_page3_mouse_exited():
	$page3/highlight.hide()


func _on_page4_mouse_entered():
	$page4/highlight.show()

func _on_page4_mouse_exited():
	$page4/highlight.hide()


func _on_page5_mouse_entered():
	$page5/highlight.show()

func _on_page5_mouse_exited():
	$page5/highlight.hide()
	

func _on_page6_mouse_entered():
	$page6/highlight.show()

func _on_page6_mouse_exited():
	$page6/highlight.hide()

func _on_page1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 1
				phone.start_phone_app("archive", event)	

func _on_page2_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 2
				phone.start_phone_app("archive", event)	

func _on_page3_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 3
				phone.start_phone_app("archive", event)	

func _on_page4_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 4
				phone.start_phone_app("archive", event)	

func _on_page5_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 5
				phone.start_phone_app("archive", event)	

func _on_page6_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 6
				phone.start_phone_app("archive", event)	
