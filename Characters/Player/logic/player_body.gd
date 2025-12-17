extends Node3D
@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

enum Hands {LEFT, RIGHT}
var UP = Vector3(0,1,0)
var RAYDIR = Vector3(0,0,-4)
var ARM_LENGTH = 0.666

@onready var PlayerRoot = $"../"
@onready var skeleton: Skeleton3D = $PlayerArmature/Armature/Skeleton3D

@onready var left_hand_target: Marker3D = $LeftHandTarget
@onready var right_hand_target: Marker3D = $RightHandTarget

@export var animation_player: AnimationPlayer
@export var footstep_audio_player : AudioStreamPlayer3D

@onready var player_armature: Node3D = $PlayerArmature

@onready var left_foot_ik_target: Marker3D = $LeftFootIKTarget
@onready var right_foot_ik_target: Marker3D = $RightFootIKTarget

@onready var step_target: Node3D = $StepTarget
@onready var left_step_target: RayCast3D = $StepTarget/LeftRayCast
@onready var right_step_target: RayCast3D = $StepTarget/RightRayCast

@onready var Hand_L_idx: int = skeleton.find_bone("Hand_L")
@onready var Hand_R_idx: int = skeleton.find_bone("Hand_R")

@onready var left_shoulder_ray: RayCast3D = $RayCastShouldderL
@onready var right_shoulder_ray: RayCast3D = $RayCastShouldderR

# ---------------------- External Targets --------------------------------------
@onready var player_rb: RigidBody3D
@onready var rb_arm_l: Node3D
@onready var rb_arm_r: Node3D

@onready var upper_body: RigidBody3D
@onready var body_attach_point: Node3D
@onready var pickup_radius: ShapeCast3D

signal ReachedTargetLeft(item: Object)
signal ReachedTargetRight(item: Object)

var stepping := false

# ---------------------- Dynamics ----------------------------------------------

var HandL_wobble = Vector3(0,0,0)
var HandR_wobble = Vector3(0,0,0)
var Head_wobble = Vector3(0,0,0)

# ----------------- debug 
var debugDraw = true
@onready var debugHelpers = [$RightFootIKTarget/debug_right_foot, $LeftFootIKTarget/debug_left_foot,
$StepTarget/LeftRayCast/LeftFootStepTarget/debug_fs_L, $StepTarget/RightRayCast/RightFootStepTarget/debug_fs_R]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_DrawIK"):
		if debugDraw:
			for helper in debugHelpers:
				helper.show()
			debugDraw = false
		else:
			for helper in debugHelpers:
				helper.show()
			debugDraw = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Temp! Used to at least have a rest pose on the character while testing IK chains
	animation_player.current_animation = "REST"
	
	left_foot_ik_target.has_started_stepping.connect(on_has_start_stepping)
	right_foot_ik_target.has_started_stepping.connect(on_has_start_stepping)
	left_foot_ik_target.has_finished_stepping.connect(footstep_audio_player.play)
	right_foot_ik_target.has_finished_stepping.connect(footstep_audio_player.play)
	
	left_shoulder_ray.target_position = RAYDIR
	right_shoulder_ray.target_position = RAYDIR


	
func on_has_start_stepping():
	if stepping:
		return
	stepping = true
	hip_step()
	
func hip_step():
	var starting = player_armature.position
	var target1 = starting + Vector3(0, -0.03, 0)
	var target2 = starting + Vector3(0, 0.04, 0)
	# Animate acring step
	var t = get_tree().create_tween()
	t.tween_property(player_armature, "position", target1, 0.2).set_ease(Tween.EASE_OUT)
	t.tween_property(player_armature, "position", target2, 0.15)
	t.tween_property(player_armature, "position", starting, 0.2).set_ease(Tween.EASE_OUT)
	t.tween_callback(func(): stepping = false)

func update_step_targets():
	var root_pos = player_rb.global_position + Vector3(0, -0.25, 0)

	var balance_vec = $"../".player_global_mass_pos - root_pos
	var speed = upper_body.linear_velocity.length()
	var left_inv_transform = self.global_transform.inverse().basis
	var local_balance_vec = left_inv_transform * balance_vec
	
	left_step_target.target_position.x = local_balance_vec.x * speed
	left_step_target.target_position.z = local_balance_vec.z * speed
	
	right_step_target.target_position.x = local_balance_vec.x * speed
	right_step_target.target_position.z = local_balance_vec.z * speed

func moveHand(ray: Object, hand: Object, target: Object, doRaycast: bool = false) -> void:
	if doRaycast:
		ray.look_at(target.global_position)
		var rayHit = ray.get_collision_point()
		hand.global_position = lerp(hand.global_position, rayHit, 0.5)
	else:
		hand.global_position = lerp(hand.global_position, target.global_position, 0.5)

func updateClosestPos() -> void:
	pass

func checkDistance(bone: Object, target: Object, hand: Hands) -> void:
	var d = (bone.global_position - target.global_position).length() - ARM_LENGTH
	if d < PlayerRoot.PickupThreshold:
		pass
		#print("----- PICKUP -----")
	else:
		pass
		#print(str(local_bone_transform) + " - " + str(global_bone_pos))
		#print(d)

func _process(delta: float) -> void:
	# Make the armature follow the physics bodies
	self.global_transform = lerp(self.global_transform, body_attach_point.global_transform, .5)
	
	#move hand targets
	match PlayerRoot.HandLState:
		Player.HandStates.REACHING: 
			if PlayerRoot.closestLeft:
				moveHand(left_shoulder_ray, left_hand_target, PlayerRoot.closestLeft, true)
				checkDistance(left_shoulder_ray, PlayerRoot.closestLeft, Hands.LEFT)
			else: moveHand(left_shoulder_ray, left_hand_target, rb_arm_l)
		_: moveHand(left_shoulder_ray, left_hand_target, rb_arm_l)
			
	match PlayerRoot.HandRState:
		Player.HandStates.REACHING: 
			if PlayerRoot.closestRight: 
				moveHand(right_shoulder_ray, right_hand_target, PlayerRoot.closestRight, true)
				checkDistance(left_shoulder_ray, PlayerRoot.closestRight, Hands.RIGHT)
			else: moveHand(right_shoulder_ray, right_hand_target, rb_arm_r)
		_: moveHand(right_shoulder_ray, right_hand_target, rb_arm_r)

	
	#move feet targets
	update_step_targets()
	
func Reset() -> void:
	pass

func _on_player_change_hand_left(state: Player.HandStates) -> void:
	match state:
		Player.HandStates.REACHING: pass
		Player.HandStates.DANGLY: pass
		
func _on_player_change_hand_right(state: Player.HandStates) -> void:
	pass

func _on_player_change_feet(state: Player.FeetStates) -> void:
	match state:
		Player.FeetStates.STEPPING: pass
		Player.FeetStates.ROLLING: pass
		
