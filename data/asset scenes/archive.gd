extends Sprite

func _ready():
	pass

func _process(delta):
	pass

func gallery_fx(node, scale):
	$fx.interpolate_property (node, "scale", node.scale, scale, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$fx.start()
