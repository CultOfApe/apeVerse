extends KinematicBody

# This whole script is a placeholder for a better player movement solution, and
# is pretty much a temporary hack copy/pasted from Godot Q&A
# currently it effectively treats the world as a 2d plane in 3d, to avoid having
# to consider slopes, stairs and such. It works, but is quite an ugly solution
# Future solution will allow for movement in any direction and even jumping.
# Furthermore it will eventually allow for 2d game movement as well
export var SPEED 	: int 		= 150
var safe_distance = 0.1

var direction 		: Vector3
var iterate 		: float 	= 0

var delayed_dialogue := {
	"id"	:	null,
	"pos"	: 	null
}

var delayed_pickup := {
	"id"	:	null,
	"pos"	: 	null	
}

var is_rotating 		: bool 		= false

onready var player 	:= self
onready var helper 	:= $"rotation_helper/Position3D"

onready var target_pos 	: Vector3
onready var player_pos 	: Vector3 	= player.get_global_transform().origin
onready var helper_pos 	: Vector3 	= helper.get_global_transform().origin	
onready var camera_pos 	: Vector3	= global.gameRoot.get_node("Camera").get_camera_transform().origin

var playerFacing 		: Vector3

var run_anim 			: bool

func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	
	if global.gameType == "3D":
		$Oleg/Armature/AnimationPlayer.play("walk")
		$Oleg/Armature/AnimationPlayer.get_animation("walk").set_loop(true)
		$Oleg/Armature/AnimationPlayer.get_animation("idle").set_loop(true)
	elif global.gameType == "2D":
		pass
	
	run_anim = true

func _physics_process(delta):
	if global.gameType == "3D":
		#move and rotate player towards set target
		if is_rotating:
			pass
		if global.playerMoving:
			if !global.blocking_ui:
				$Oleg/Armature/AnimationPlayer.play("walk")
				turn_towards(delta)
				move_and_slide(Vector3(playerFacing) * get_physics_process_delta_time() * SPEED)
				if player_pos.distance_to(target_pos) < safe_distance:
					global.playerMoving = false
					if delayed_dialogue.id != null:
						get_node("../dialogue")._talk_to(delayed_dialogue.id, delayed_dialogue.pos, "default")
						delayed_dialogue = {
							"id"	:	null,
							"pos"	:	null
						}
					if delayed_pickup.id != null:
						get_node("../objects/" + delayed_pickup.id).pickup()
						delayed_pickup = {
							"id"	:	null,
							"pos"	:	null
						}

					
		elif global.playerMoving == false and run_anim == true:
			$Oleg/Armature/AnimationPlayer.play("idle")
			run_anim = false
			
		if global.playerMoving and global.blocking_ui == true:
				$Oleg/Armature/AnimationPlayer.stop()

	elif global.gameType == "2D":
		pass
		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				# if mouse over NPC or object, we need this to move player towards
				if global.itemInHand == "" and global.hover.position != null:
					if global.hover.type == "object":
						delayed_pickup = {
							"id"	:	global.hover.id,
							"pos"	: 	global.hover.position	
						}
						move(global.hover.position)
					elif global.hover.type == "npc":
						delayed_dialogue = {
							"id"	:	global.hover.id,
							"pos"	:	global.hover.position
						}
						move(global.hover.position)


func turn_towards(delta):
	if global.gameType == "3D":
		var player_transform := player.transform
		var direction := player_transform.looking_at(target_pos,Vector3(0,1,0))
		var rotation := Quat(player_transform.basis).slerp(direction.basis, iterate*0.3)
		
		if iterate < 1:
			iterate += delta
		player.transform = Transform(rotation, player_transform.origin)
		player_pos = player.get_global_transform().origin
		helper_pos = helper.get_global_transform().origin	
		playerFacing = (helper_pos - player_pos).normalized()
	elif global.gameType == "2D":
		pass

func _on_scene_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and !global.blocking_ui:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				move(click_position)

	else:
		#need to add this so player doesn´t move when exiting dialog
		direction = Vector3(0,0,0)
	
func move(click_position):
# if an object or npc under the mouse, walk to a safe distance, and then stop
	if global.hover.type != null:
		safe_distance = 1
	else:
		safe_distance = 0.1
		
	$Character/AnimationPlayer.play("Run")
	$Oleg/Armature/AnimationPlayer.play("walk")
		
	global.playerMoving = true
	
	iterate = 0 
	player_pos = player.get_global_transform().origin
	helper_pos = helper.get_global_transform().origin
	target_pos = click_position
	
	var cross := get_node("../cross")
	var tween := get_node("../cross/tween")
	
	cross.frame = 1
	cross.position = get_node("../Camera").unproject_position(click_position)
	cross.play()
	
	tween.interpolate_property(cross, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	run_anim = true
		

