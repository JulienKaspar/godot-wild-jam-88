extends Node3D
@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

@export var left_hand_target: Node3D
@export var right_hand_target: Node3D

@export var animation_player: AnimationPlayer
@export var footstep_audio_player : AudioStreamPlayer3D

@onready var player_armature: Node3D = $PlayerArmature

@onready var left_foot_ik_target: Marker3D = $LeftFootIKTarget
@onready var right_foot_ik_target: Marker3D = $RightFootIKTarget

@onready var step_target: Node3D = $StepTarget
@onready var left_step_target: RayCast3D = $StepTarget/LeftRayCast
@onready var right_step_target: RayCast3D = $StepTarget/RightRayCast

@onready var player_rb: RigidBody3D
@onready var rb_arm_l: Node3D
@onready var rb_arm_r: Node3D

@onready var upper_body: RigidBody3D
@onready var body_attach_point: Node3D
@onready var pickup_radius: ShapeCast3D


signal ReachedTargetLeft(item: Object)
signal ReachedTargetRight(item: Object)

var stepping := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Temp! Used to at least have a rest pose on the character while testing IK chains
	animation_player.current_animation = "REST"
	
	left_foot_ik_target.has_started_stepping.connect(on_has_start_stepping)
	right_foot_ik_target.has_started_stepping.connect(on_has_start_stepping)
	left_foot_ik_target.has_finished_stepping.connect(footstep_audio_player.play)
	right_foot_ik_target.has_finished_stepping.connect(footstep_audio_player.play)

	
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

func _process(delta: float) -> void:
	# Make the armature follow the physics bodies
	self.global_transform = lerp(self.global_transform, body_attach_point.global_transform, .5)
	left_hand_target.global_transform = lerp(left_hand_target.global_transform, rb_arm_l.global_transform, 0.5)
	right_hand_target.global_transform = lerp(right_hand_target.global_transform, rb_arm_r.global_transform, 0.5)
	update_step_targets()
	
func Reset() -> void:
	pass

func _on_player_change_hand_left(state: Player.HandStates) -> void:
	pass

func _on_player_change_hand_right(state: Player.HandStates) -> void:
	pass

func _on_player_change_feet(state: Player.FeetStates) -> void:
	match state:
		Player.FeetStates.IK: pass
		Player.FeetStates.ROLLING: pass
		

func _on_player_change_hand_target_l(trgt_left: Object, isValid: bool) -> void:
	pass # Replace with function body.

func _on_player_change_hand_target_r(trgt_right: Object, isValid: bool) -> void:
	pass # Replace with function body.
