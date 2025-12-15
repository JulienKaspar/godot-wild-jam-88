extends Node3D
class_name Player

@warning_ignore_start('unused_signal')
signal ChangeHandLeft(active: HandStates)
signal ChangeHandRight(active: HandStates)
signal ChangeFeet(active: FeetStates)
signal ChangeHandTargetL(trgt_left: Object, isValid: bool) # set isValid=false if theres none
signal ChangeHandTargetR(trgt_right: Object, isValid: bool) # set isValid=false if theres none
signal ChangeMovement(state: MoveStates)
signal ConsumedDrunkness(value:float)

@onready var player_body: Node3D = $PlayerBody
@onready var step_target: Node3D = $PlayerBody/StepTarget
@onready var left_step_target: RayCast3D = $PlayerBody/StepTarget/LeftRayCast
@onready var right_step_target: RayCast3D = $PlayerBody/StepTarget/RightRayCast

@onready var player_rb: RigidBody3D = $PlayerController/RigidBally3D
@onready var rb_arm_l: Node3D = $PlayerController/ArmL
@onready var rb_arm_r: Node3D = $PlayerController/ArmR

@onready var upper_body: RigidBody3D = $PlayerController/UpperBody
@onready var body_attach_point: Node3D = $PlayerController/UpperBody/BodyAttachPoint
@onready var pickup_radius: ShapeCast3D = $PickupRadius

@onready var left_hand_target: Node3D = $LeftHandTarget
@onready var right_hand_target: Node3D = $RightHandTarget

### statess 
enum MoveStates {IDLE, MOVING, FALLING, ROLLING, FLASKY, FELL}
enum HandStates {DANGLY, REACHING, HOLD, DRINKING, ROLLING, FIXED}
enum FeetStates {IK, REACHING, HOLD, DRINKING, ROLLING, FIXED}

# input states
var grabbingL = false
var grabbingR = false

# move state
var inMoveState = MoveStates.IDLE
var HandLState = HandStates.DANGLY
var HandRState = HandStates.DANGLY
var canRoll = true
var player_speed = 0.0 # owned by player_controller
var player_move_dir = Vector2(0,0) # owned by player_controller
var player_global_pos = Vector3(0,0,0) # owned by player_controller
var player_global_mass_pos = Vector3(0,0,0) # owned by player_controller
var player_facing_dir = Vector2(0,1.0) # owned by player_controller
var leaning = 0.0 # owned by player_controller

# health and safety
var drunk_amount = 0.5


#----------------------------------------

func goRoll() -> void:
	pass
	
func setHandLState(state: HandStates):
	HandLState = state
	self.ChangeHandLeft.emit(state)

func setHandRState(state: HandStates):
	HandLState = state
	self.ChangeHandRight.emit(state)

func _process(_delta: float) -> void:
	# Make the armature follow the physics bodies
	player_body.global_transform = lerp(player_body.global_transform, body_attach_point.global_transform, .5)
	left_hand_target.global_transform = lerp(left_hand_target.global_transform, rb_arm_l.global_transform, 0.5)
	right_hand_target.global_transform = lerp(right_hand_target.global_transform, rb_arm_r.global_transform, 0.5)

	update_step_targets()
	# ------- Input Handling ------
	if Input.is_action_pressed("grab_left"):
		grabbingL = true
		if HandLState == HandStates.DANGLY: 
			setHandLState(HandStates.REACHING)
	else:
		grabbingL = false
		if HandLState == HandStates.REACHING: 
			setHandLState(HandStates.DANGLY)
			
	if Input.is_action_pressed("grab_right"):
		grabbingR = true
		if HandRState == HandStates.DANGLY: 
			setHandRState(HandStates.REACHING)
	else:
		grabbingR = false
		if HandRState == HandStates.REACHING: 
			setHandRState(HandStates.DANGLY)
		
	if Input.is_action_just_pressed("roll"):
		if canRoll:
			goRoll()
		else:
			# WIP, player feedback fo unsuccessfull roll?
			pass
	
func update_step_targets():
	var root_pos = player_rb.global_position + Vector3(0, -0.25, 0)

	var balance_vec = player_global_mass_pos - root_pos
	var speed = upper_body.linear_velocity.length() * 1.5
	var left_inv_transform = player_body.global_transform.inverse().basis
	var local_balance_vec = left_inv_transform * (balance_vec * 2)
	
	left_step_target.target_position.x = local_balance_vec.x * speed
	left_step_target.target_position.z = local_balance_vec.z * speed
	
	right_step_target.target_position.x = local_balance_vec.x * speed
	right_step_target.target_position.z = local_balance_vec.z * speed

func _on_player_body_reached_target_left(item) -> void:
	if item.get_script().get_global_name() == "DrunknessPickup":
		setHandLState(HandStates.HOLD)
	else:
		setHandLState(HandStates.FIXED)

func _on_player_body_reached_target_right(item) -> void:
	if item.get_script().get_global_name() == "DrunknessPickup":
		setHandRState(HandStates.HOLD)
	else:
		setHandRState(HandStates.FIXED)
