extends Node

func _ready():
	global.change_cursor("default")
	
	$"ui/date".set_text(global.gameData.time[0] + ", " + global.weekday)	
	
	global.scene = "schoolyard"
	global.load_scene("schoolyard")

func _process(_delta):
	pass

