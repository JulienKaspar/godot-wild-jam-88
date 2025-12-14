extends Node3D

@onready var player_body: Node3D = $".."
@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D

@onready var left_foot_target: Marker3D = $"../LeftFootIKTarget"
@onready var right_foot_target: Marker3D = $"../RightFootIKTarget"

func _ready() -> void:
	# Setup IK for left arm
	var left_arm_ik = SkeletonIK3D.new()
	left_arm_ik.root_bone = "Arm_L"
	left_arm_ik.tip_bone = "Hand_L"
	left_arm_ik.target_node = player_body.left_hand_target.get_path()
	left_arm_ik.use_magnet = true
	left_arm_ik.magnet = Vector3(1, 0, -1)
	left_arm_ik.start()
	skeleton_3d.add_child(left_arm_ik)
	
	# Setup IK for right arm
	var right_arm_ik = SkeletonIK3D.new()
	right_arm_ik.root_bone = "Arm_R"
	right_arm_ik.tip_bone = "Hand_R"
	right_arm_ik.target_node = player_body.right_hand_target.get_path()
	right_arm_ik.use_magnet = true
	right_arm_ik.magnet = Vector3(-1, 0, -1)
	right_arm_ik.start()
	skeleton_3d.add_child(right_arm_ik)
	
	var left_leg_ik = SkeletonIK3D.new()
	left_leg_ik.root_bone = "Leg_L"
	left_leg_ik.tip_bone = "Leg_IK_target-L"
	left_leg_ik.target_node = left_foot_target.get_path()
	left_leg_ik.use_magnet = true
	left_leg_ik.magnet = Vector3(0, 0, 1)
	left_leg_ik.start()
	skeleton_3d.add_child(left_leg_ik)
	
	var right_leg_ik = SkeletonIK3D.new()
	right_leg_ik.root_bone = "Leg_R"
	right_leg_ik.tip_bone = "Leg_IK_target-R"
	right_leg_ik.target_node = right_foot_target.get_path()
	right_leg_ik.use_magnet = true
	right_leg_ik.magnet = Vector3(0, 0, 1)
	right_leg_ik.start()
	skeleton_3d.add_child(right_leg_ik)
