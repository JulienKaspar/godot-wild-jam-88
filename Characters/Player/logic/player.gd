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
func _ready() -> void:
	# need to set these from here as they might not exist in the body when its ready
	$PlayerBody.player_rb = $PlayerController/RigidBally3D
	$PlayerBody.rb_arm_l = $PlayerController/ArmL
	$PlayerBody.rb_arm_r = $PlayerController/ArmR
	$PlayerBody.upper_body = $PlayerController/UpperBody
	$PlayerBody.body_attach_point = $PlayerController/UpperBody/BodyAttachPoint
	$PlayerBody.pickup_radius = $PickupRadius

func goRoll() -> void:
	pass
	
func setHandLState(state: HandStates):
	HandLState = state
	self.ChangeHandLeft.emit(state)

func setHandRState(state: HandStates):
	HandRState = state
	self.ChangeHandRight.emit(state)

func _process(_delta: float) -> void:
	# Make the armature follow the physics bodies

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
