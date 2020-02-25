extends Area
signal on_click(a)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_triggers_body_entered(player):
	global.is_moving = false
	emit_signal("on_click", "schoolhall")
