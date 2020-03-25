extends Panel

signal avatar_clicked

var id
var frameCount

func _ready():
	$avatar.set_frame(0)
	$frame.set_text("FRAME: " + String($avatar.get_frame()))
	frameCount = $avatar.get_sprite_frames().get_frame_count("default")

func _on_Button_pressed():
	emit_signal("avatar_clicked")

func _on_previous_pressed():
	if $avatar.get_frame() <= $avatar.get_sprite_frames().get_frame_count("default"):
		$avatar.set_frame($avatar.get_frame() - 1)
		$frame.set_text("FRAME: " + String($avatar.get_frame()))

func _on_next_pressed():
	if $avatar.get_frame() >= -1:
		$avatar.set_frame($avatar.get_frame() + 1)
		$frame.set_text("FRAME: " + String($avatar.get_frame()))
