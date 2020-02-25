extends KinematicBody

# This whole script is a placeholder for a better player movement solution, and
# is pretty much a temporary hack copy/pasted from Godot Q&A
# currently it effectively treats the world as a 2d plane in 3d, to avoid having
# to consider slopes, stairs and such. It works, but is quite an ugly solution
# Future solution will allow for movement in any direction and even jumping.
# Furthermore it will eventually allow for 2d game movement as well

var direction 			: Vector3
const SPEED 			: int = 150
var turnIter 			: float = 0

var isRotating 			: bool = false

onready var player 		: Object = self
onready var helper 		: Object  = $"rotation_helper/Position3D"

onready var target_pos 	: Vector3
onready var player_pos 	: Vector3 = player.get_global_transform().origin
onready var helper_pos 	: Vector3 = helper.get_global_transform().origin	

var playerFacing 		: Vector3

var run_anim 			: bool

func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	if global.gameType == "3D":
		$Character/AnimationPlayer.play("Run")
		$Character/AnimationPlayer.get_animation("Run").set_loop(true)
		$Character/AnimationPlayer.get_animation("Idle-loop").set_loop(true)
		
		$Oleg/Armature/AnimationPlayer.play("walk")
		$Oleg/Armature/AnimationPlayer.get_animation("walk").set_loop(true)
		$Oleg/Armature/AnimationPlayer.get_animation("idle").set_loop(true)
	elif global.gameType == "2D":
		pass
	
	run_anim = true
#needs a separate flag because right now this stops player even if I´m only hovering a UI icon	
#func _process(delta):
#	if global.sceneCol.disabled == true:
#		global.is_moving = false
#		$Character/AnimationPlayer.stop()

func _physics_process(delta):
	if global.gameType == "3D":
		#move and rotate player towards set target
		if isRotating:
			pass
		if global.is_moving:
			if global.blocking_ui != true:
				$Character/AnimationPlayer.play("Run")
				$Oleg/Armature/AnimationPlayer.play("walk")
				turn_towards()
				move_and_slide(Vector3(playerFacing) * get_physics_process_delta_time() * SPEED)
				if player_pos.distance_to(target_pos) < 0.5:
					global.is_moving = false
					
		elif global.is_moving == false and run_anim == true:
			$Character/AnimationPlayer.play("Idle-loop")
			$Oleg/Armature/AnimationPlayer.play("idle")
			run_anim = false
			
		if global.is_moving and global.blocking_ui == true:
				$Character/AnimationPlayer.stop()
				$Oleg/Armature/AnimationPlayer.stop()

	elif global.gameType == "2D":
		pass

func turn_towards():
	if global.gameType == "3D":
		var t = player.get_transform()
#		var lookDir = target_pos - player_pos
		var rotTransform = t.looking_at(target_pos,Vector3(0,1,0))
		var thisRotation = Quat(t.basis).slerp(rotTransform.basis,turnIter*0.3)
		if turnIter < 1:
			turnIter += get_physics_process_delta_time()
		player.set_transform(Transform(thisRotation,t.origin))	
		player_pos = player.get_global_transform().origin
		helper_pos = helper.get_global_transform().origin	
		playerFacing = (helper_pos - player_pos).normalized()
	elif global.gameType == "2D":
		pass

#	Some quick code that will be used for 2d adventure games. Unfinished.
#	target_position = vector2(2, 5)
#	player_position = vector2(3, 8)
#
#	direction_vector = target_position - player_position
#	if direction_vector.x < 0:
#		player_direction_x = "left"
#	else:
#		player_direction_x = "right"
#
#	if direction_vector.y < 0:
#		player_direction_y = "up"
#	else:
#		player_direction_y = "down"
#
#	var real_numbers = abs(direction_vector)
#
#	if real_numbers.x > real_numbers.y:
#		sprite_animation = player_direction_x
#	else:
#		sprite_animation = player_direction_y

#this func don´t need any flag for 2d, since 2d games will have an area2s click area instead
func _on_scene_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and global.blocking_ui != true:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if !global.is_moving:
					$Character/AnimationPlayer.play("Run")
					$Oleg/Armature/AnimationPlayer.play("walk")
					
				global.is_moving = true
				
				turnIter = 0 
				player_pos = player.get_global_transform().origin
				helper_pos = helper.get_global_transform().origin
				target_pos = click_position
				
				var cross = get_node("../cross")
				var tween = get_node("../cross/tween")
				
				cross.frame = 1
				cross.position = get_node("../Camera").unproject_position(click_position)
				cross.play()
				
				tween.interpolate_property(cross, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
				
				run_anim = true

	else:
		#need to add this so player doesn´t move when exiting dialog
		direction = Vector3(0,0,0)
