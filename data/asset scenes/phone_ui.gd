extends Area2D

var folder : Array
var gallery : Array
var gallery_thumbs : Array

onready var contactNode = get_node("apps/phone/contact_node")

func _ready():
	# TODO: This should only be run when the PhoneUI is envoked and then folder var should be emptied
	folder = global.list_files_in_directory("res://data/graphics/gallery/")
	#list all files in given directory and sort into fullsized photos (gallery) and thumbnails (gallery_thumbs) 
	for item in folder:
		if "thumb" in item:
			gallery_thumbs.push_back(item)
		else:
			gallery.push_back(item)
			
	contactNode.connect("call", self, "_on_call")

func _input(event):
	if event is InputEventKey:
		#if any phone app is running and we press Q, close the app and return to homescreen
		if event.scancode == KEY_Q:
			if global.phone_app_running == true:
				if event.is_pressed():
					for app in $apps.get_children():
						app.hide()			
					global.phone_app_running = false

func icon_fx(node, scale):
	$fx.interpolate_property (node, "scale", node.scale, scale, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$fx.start()

func start_phone_app(app, event):
	if app == "phone":
		#display phone contacts
		for contact in global.contactData.contacts:
			var node = load("res://data/asset scenes/contact_node.tscn")
			node = node.instance()
			node.set_name("contact" + contact)
#			node.set_position(Vector2(30, 30))
			self.add_child(node)
#			get_node(node + str(contact+1)).set_text(global.contactData["c" + str(contact+1)])
			
	if app == "archive":
		var node = "apps/archive/Sprite"
		var page_number = "apps/archive/page"
		var i = 1
		var slot = 1
		
		#get how many gallery pages are required to display all images
		var pagenumbers_shown = ceil(float(gallery_thumbs.size())/6)
		
		#first hide all images and show only amount of pages required
		for i in range(6):
			get_node(node + str(i+1)).hide()
			if i < pagenumbers_shown:
				get_node(page_number + str(i+1)).show()
			else:
				get_node(page_number + str(i+1)).hide()
		
		#now only show the image slots assigned images
		for thumb in gallery_thumbs:
			#Assign thumb textures corresponding to gallery page. If page is 3, assign textures in gallery_thumbs[13] to[18] 
			if i < global.gallery_page * 6 +1 and i > global.gallery_page * 6 - 6:
				var image = load("res://data/graphics/gallery/" + thumb)
				get_node(node + str(slot)).set_texture(image)
				get_node(node + str(slot)).show()
				slot += 1
			i = i+1
		
	if event is InputEventMouseButton and !global.phone_app_running:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				get_node("apps/" + app).show()
				global.phone_app_running = true
				
func _on_phone_mouse_entered():
	icon_fx($homescreen/phone, Vector2(0.9, 0.9))

func _on_phone_mouse_exited():
	icon_fx($homescreen/phone, Vector2(1, 1))

func _on_phone_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				start_phone_app("phone", event)


func _on_mail_mouse_entered():
	icon_fx($homescreen/mail, Vector2(0.9, 0.9))

func _on_mail_mouse_exited():
	icon_fx($homescreen/mail, Vector2(1, 1))

func _on_mail_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				start_phone_app("mail", event)


func _on_internet_mouse_entered():
	icon_fx($homescreen/internet, Vector2(0.9, 0.9))

func _on_internet_mouse_exited():
	icon_fx($homescreen/internet, Vector2(1, 1))

func _on_internet_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				start_phone_app("internet", event)


func _on_archive_mouse_entered():
	icon_fx($homescreen/archive, Vector2(0.9, 0.9))

func _on_archive_mouse_exited():
	icon_fx($homescreen/archive, Vector2(1, 1))

func _on_archive_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				start_phone_app("archive", event)


func _on_calendar_mouse_entered():
	icon_fx($homescreen/calendar, Vector2(0.9, 0.9))

func _on_calendar_mouse_exited():
	icon_fx($homescreen/calendar, Vector2(1, 1))

func _on_calendar_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				start_phone_app("calendar", event)


func _on_games_mouse_entered():
	icon_fx($homescreen/games, Vector2(0.9, 0.9))

func _on_games_mouse_exited():
	icon_fx($homescreen/games, Vector2(1, 1))

func _on_games_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				 start_phone_app("games", event)


func _on_page1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 1
				start_phone_app("archive", event)


func _on_page2_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 2
				start_phone_app("archive", event)	


func _on_page3_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				global.gallery_page = 3
				start_phone_app("archive", event)

func _on_call(id):
	get_parent().ui_exit(null)
	global.blocking_ui = true
	get_node("../../dialogue")._talk_to("devaun", Vector3(1,1,1), "phone")
