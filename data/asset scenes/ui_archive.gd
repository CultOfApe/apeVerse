extends Panel

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
				print($"../full_view".rect_position)
				print($"../full_view".rect_scale)
				$"../full_view".rect_position = Vector2(800, 1800)
				$"../full_view/sprite".set_texture($Sprite1.get_texture())
				
				$"../full_view".show()
				$galleryFX.interpolate_property($"../full_view", "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$galleryFX.interpolate_property($"../full_view", "rect_position", $"../full_view".rect_position, $"../full_view".rect_position + Vector2(400,-230), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$galleryFX.interpolate_property($"../full_view", "rect_scale", $"../full_view".rect_scale, Vector2(4,4), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$galleryFX.start()
				
func _on_sprite2_mouse_entered():
	icon_fx($Sprite2, Vector2(1.1, 1.1))

func _on_sprite2_mouse_exited():
	icon_fx($Sprite2, Vector2(1, 1))

func _on_sprite2_input_event():
	global.gallery_page = 1


func _on_sprite3_mouse_entered():
	icon_fx($Sprite3, Vector2(1.1, 1.1))

func _on_sprite3_mouse_exited():
	icon_fx($Sprite3, Vector2(1, 1))

func _on_sprite3_input_event():
	global.gallery_page = 1


func _on_sprite4_mouse_entered():
	icon_fx($Sprite4, Vector2(1.1, 1.1))

func _on_sprite4_mouse_exited():
	icon_fx($Sprite4, Vector2(1, 1))

func _on_sprite4_input_event():
	global.gallery_page = 1


func _on_sprite5_mouse_entered():
	icon_fx($Sprite5, Vector2(1.1, 1.1))

func _on_sprite5_mouse_exited():
	icon_fx($Sprite5, Vector2(1, 1))

func _on_sprite5_input_event():
	global.gallery_page = 1


func _on_sprite6_mouse_entered():
	icon_fx($Sprite6, Vector2(1.1, 1.1))

func _on_sprite6_mouse_exited():
	icon_fx($Sprite6, Vector2(1, 1))

func _on_sprite6_input_event():
	pass


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

