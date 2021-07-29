extends Panel

signal new_item_materialized(a) 


func _ready():
	pass # Replace with function body.


func _on_materialize_tween_completed(object, key):
	emit_signal("new_item_materialized", self)
