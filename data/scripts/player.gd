class_name Player

extends KinematicBody

# This whole script is a placeholder for a better player movement solution, and
# is pretty much a temporary hack copy/pasted from Godot Q&A
# currently it effectively treats the world as a 2d plane in 3d, to avoid having
# to consider slopes, stairs and such. It works, but is quite an ugly solution
# Future solution will allow for movement in any direction and even jumping.
# Furthermore it will eventually allow for 2d game movement as well
export var SPEED 	: int 		= 150
var safe_distance = 0.1
var iterate 		: float 	= 0

var delayed_dialogue := {
	"id"	:	null,
	"pos"	: 	null
}

var delayed_pickup := {
	"id"	:	null,
	"pos"	: 	null	
}

var delayed_gift := {
	"id"	:	null,
	"pos"	: 	null	
}

var is_rotating 		: bool 		= false

onready var player 	:= self

onready var target_pos 	: Vector3
onready var player_pos 	: Vector3 	= player.get_global_transform().origin

var run_anim 			: bool

func _ready():
	$Oleg/Armature/AnimationPlayer.play("walk")
	$Oleg/Armature/AnimationPlayer.get_animation("walk").set_loop(true)
	$Oleg/Armature/AnimationPlayer.get_animation("idle").set_loop(true)
	
	run_anim = true
	
func _process(delta):
	#set anchor for reactions slightly above head
	$ui_anchor.set_position(global.camera.unproject_position(self.translation - Vector3(0, -2.2, 0)))

func _physics_process(delta):
	#move and rotate player towards set target
	if global.playerMoving:
		if !global.blocking_ui:
			$Oleg/Armature/AnimationPlayer.play("walk")
			turn_towards(delta)
			move_and_slide(-get_global_transform().basis.z * get_physics_process_delta_time() * SPEED)
			if player_pos.distance_to(target_pos) < safe_distance:
				global.playerMoving = false
				if delayed_dialogue.id != null:
					$"/root/game/dialogue".talk_to(delayed_dialogue.id, delayed_dialogue.pos, "default")
					delayed_dialogue = {
						"id"	:	null,
						"pos"	:	null
					}
				if delayed_pickup.id != null:
					get_node("/root/game/objects/" + delayed_pickup.id).pickup()
					delayed_pickup = {
						"id"	:	null,
						"pos"	:	null
					}
					delayed_pickup.id = null
				if delayed_gift.id != null:
					get_node("/root/game/npcs/" + delayed_gift.id).itemGiven(global.itemInHand)
					delayed_gift = {
						"id"	:	null,
						"pos"	:	null
					}

				
	elif global.playerMoving == false and run_anim == true:
		$Oleg/Armature/AnimationPlayer.play("idle")
		run_anim = false
		
	if global.playerMoving and global.blocking_ui == true:
			$Oleg/Armature/AnimationPlayer.stop()
		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				# if mouse over NPC or object, we need this to move player towards
				if global.hover.position != null:
					if global.itemInHand == "":
						if global.hover.type == "object":
							delayed_pickup = {
								"id"	:	global.hover.id,
								"pos"	: 	global.hover.position	
							}
							move(global.hover.position)
						elif global.hover.type == "npc" and global.itemInHand == "":
							delayed_dialogue = {
								"id"	:	global.hover.id,
								"pos"	:	global.hover.position
							}
							move(global.hover.position)
					else:
						delayed_gift = {
							"id"	:	global.hover.id,
							"pos"	:	global.hover.position
						}
						move(global.hover.position)


func turn_towards(delta):
	var player_transform := player.transform
	var direction = player_transform.looking_at(target_pos,Vector3(0,1,0))
	var rotation := Quat(player_transform.basis).slerp(direction.basis, iterate * 0.3)
	
	if iterate < 1:
		iterate += delta
	player.transform = Transform(rotation, player_transform.origin)
	player_pos = player.get_global_transform().origin

func _on_scene_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and !global.blocking_ui:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				move(click_position)
	
func move(click_position):
# if an object or npc under the mouse, walk to a safe distance, and then stop
	if global.hover.type != null:
		safe_distance = 1.5
	else:
		safe_distance = 0.1

	$Oleg/Armature/AnimationPlayer.play("walk")
	
	iterate = 0 
	player_pos = player.get_global_transform().origin
	target_pos = click_position
	
	global.playerMoving = true
	run_anim = true

func dissolve():
	$"tweens/tween_out".interpolate_property($"ui_anchor", "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$"tweens/tween_out".start()
	global.lookingAt = false

func _on_tween_in_tween_completed(object, key):
	global.wait_and_execute(2, "dissolve", self)

func _on_tween_out_tween_completed(object, key):
	pass # Replace with function body.
