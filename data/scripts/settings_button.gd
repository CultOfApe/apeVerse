extends Button

func _ready():
	pass

func _on_settings_button_down():
	global.goto_scene("menu_settings.tscn")

