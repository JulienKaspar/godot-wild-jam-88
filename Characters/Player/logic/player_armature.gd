@tool

extends Node3D

@onready var player_body: Node3D = $".."
@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup IK for left arm
	var left_arm_ik = SkeletonIK3D.new()
	left_arm_ik.root_bone = "Arm_L"
	left_arm_ik.tip_bone = "Hand_L"
	left_arm_ik.target_node = player_body.left_hand_target.get_path()
	left_arm_ik.start()
	skeleton_3d.add_child(left_arm_ik)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
