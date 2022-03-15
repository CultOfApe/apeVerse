extends Button

signal call(a)

var id : String

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	emit_signal("call", id)
