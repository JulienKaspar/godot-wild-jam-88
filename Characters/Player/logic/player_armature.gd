extends Node3D

@onready var player_body: Node3D = $".."
@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D

@export var left_foot_target: Marker3D
@export var right_foot_target: Marker3D
@export var left_hand_target: Marker3D
@export var right_hand_target: Marker3D
@export var lookat_target: Marker3D

var hand_attach_l: BoneAttachment3D
var hand_attach_r: BoneAttachment3D

func _ready() -> void:
	# Setup IK for left arm
	get_tree()
	var left_arm_ik = SkeletonIK3D.new()
	left_arm_ik.root_bone = "Arm_L"
	left_arm_ik.tip_bone = "Hand_L"
	left_arm_ik.target_node = left_hand_target.get_path()
	left_arm_ik.use_magnet = true
	left_arm_ik.magnet = Vector3(1, 0, -1)
	left_arm_ik.start()
	skeleton_3d.add_child(left_arm_ik)
	
	# Setup IK for right arm
	var right_arm_ik = SkeletonIK3D.new()
	right_arm_ik.root_bone = "Arm_R"
	right_arm_ik.tip_bone = "Hand_R"
	right_arm_ik.target_node = right_hand_target.get_path()
	right_arm_ik.use_magnet = true
	right_arm_ik.magnet = Vector3(-1, 0, -1)
	right_arm_ik.start()
	skeleton_3d.add_child(right_arm_ik)
	
	var left_leg_ik = SkeletonIK3D.new()
	left_leg_ik.root_bone = "Leg_L"
	left_leg_ik.tip_bone = "Leg_IK_target-L"
	left_leg_ik.target_node = left_foot_target.get_path()
	left_leg_ik.use_magnet = true
	left_leg_ik.magnet = Vector3(2, 0, 5)
	left_leg_ik.start()
	skeleton_3d.add_child(left_leg_ik)
	
	var right_leg_ik = SkeletonIK3D.new()
	right_leg_ik.root_bone = "Leg_R"
	right_leg_ik.tip_bone = "Leg_IK_target-R"
	right_leg_ik.target_node = right_foot_target.get_path()
	right_leg_ik.use_magnet = true
	right_leg_ik.magnet = Vector3(-2, 0, 5)
	right_leg_ik.start()
	skeleton_3d.add_child(right_leg_ik)
	
	#var hair_wobble = SpringBoneSimulator3D.new()
	#hair_wobble.set_end_bone_name(1, "Hair")
	#hair_wobble.set_root_bone_name(0, "Head")
	#skeleton_3d.add_child(hair_wobble)
	
	var head_lookat = LookAtModifier3D.new()
	head_lookat.bone_name = "Head"
	head_lookat.forward_axis = SkeletonModifier3D.BONE_AXIS_PLUS_Z
	head_lookat.target_node = lookat_target.get_path()
	head_lookat.primary_limit_angle = 3
	head_lookat.primary_damp_threshold = 0.0
	head_lookat.ease_type = Tween.EASE_IN_OUT
	head_lookat.secondary_limit_angle = 3
	head_lookat.duration = 0.5
	head_lookat.use_angle_limitation = true
	head_lookat.use_secondary_rotation = true
	head_lookat.symmetry_limitation = true
	#head_lookat.use_secondary_rotation = true 

	head_lookat.active = true
	skeleton_3d.add_child(head_lookat)
	
	hand_attach_l = BoneAttachment3D.new()
	hand_attach_r = BoneAttachment3D.new()
	hand_attach_l.bone_name = "Hand_L"
	hand_attach_r.bone_name = "Hand_L"
