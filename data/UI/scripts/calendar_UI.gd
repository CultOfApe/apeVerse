extends Area2D

onready var calendar_node 	: Object	= load("res://data/ui/nodes/calendar_node.tscn")
onready var header_node 	: Object	= load("res://data/ui/nodes/header_node.tscn")

var currentMonth 	: int = global.monthNum - 1
var currentDay 		: int = global.day - 1 # set to less than current day, to ensure initial population of calendar

func _ready():
	_update()

func _process(delta):
	if global.update_calendar == true:
		_update()
	else:
		pass

func _update():
	$lbl_month.set_text(global.gameData.month[global.monthNum-1])
	var offsetY : int = 0
	var offsetX : int  = 0
	var offsetDay : int  = global.calendarOffset
	var new_week : int  = 0 
	var event_label : String
		
	if currentMonth < global.monthNum:		
		#setup the calendar header (monday, tuesday....)
		for i in range(7):
			offsetX = i*165
			var node = header_node.instance()
			node.set_name(global.gameData["weekday"][i])
			node.set_position(Vector2(125 + offsetX,85 + offsetY))
			$nodes.add_child(node)
			get_node("nodes/" + global.gameData["weekday"][i] +"/label").set_text(global.gameData["weekday"][i])
			
		#setup the calendar cells (where days and events are displayed)
		#35 because we need 5 rows of 7 to display the whole month
		
		for i in range(35):
			event_label = ""
			offsetX = i*165 - new_week
				
			var node : Object = calendar_node.instance()
			node.set_name(str(i))
			node.set_position(Vector2(125 + offsetX,130 + offsetY))
			$nodes.add_child(node)
				
			if i > offsetDay - 2 and i < 30 + offsetDay - 1:
				if global.eventData["date"].has(str(i-(offsetDay-2))):
					var date = global.eventData["date"][str(i-(offsetDay-2))]["evening"]
	#				currentMonth.push_back("event")
					event_label = date["event"]#				current_month[i-1] = "event"
					var icon = Sprite.new()
					var texture = load("res://data/ui/graphics/" + date.icon)
					icon.set_position(Vector2(200 + offsetX,200 + offsetY))
					icon.set_scale(Vector2(0.5, 0.5))
					icon. set_texture(texture)
					$nodes.add_child(icon)
				else:
	#				currentMonth.push_back("blank")
					event_label = ""
				
			if i  >= offsetDay  and i < offsetDay + 30:
				get_node("nodes/"+str(i)+"/label_day").set_text(str(i - (offsetDay)+1))
		
			#this is just to test the color override. TODO: check if calendar day is the same as global.gameDay
			if i == offsetDay + (global.day - global.firstofmonth):
				get_node("nodes/"+str(i)+"/label_day").add_color_override("font_color", Color(1,0,0,1))
				
			#if we reach 7 days, increment offsetY to start a new row
			if i==6 or i==13 or i==20 or i==27:
					#I should handle these offsets in a more elegant, dynamic way, instead of hardcoding them...
					offsetY += 155
					new_week += 1155
			
		currentMonth = global.monthNum
		
	if currentDay < global.day:
		get_node("nodes/"+str(offsetDay + (global.day - global.firstofmonth) - 1)+"/label_day").add_color_override("font_color", Color(1,1,1,1))
		get_node("nodes/"+str(offsetDay + (global.day - global.firstofmonth))+"/label_day").add_color_override("font_color", Color(1,0,0,1))
				
	global.update_calendar = false
