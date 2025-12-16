extends Node3D
class_name Player

@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

signal ChangeHandLeft(state: HandStates)
signal ChangeHandRight(state: HandStates)
signal ChangeFeet(state: FeetStates)
signal ChangeHandTargetL(trgt_left: Object, isValid: bool) # set isValid=false if theres none
signal ChangeHandTargetR(trgt_right: Object, isValid: bool) # set isValid=false if theres none
signal ChangeMovement(state: MoveStates)
signal ConsumedDrunkness(value:float)

@onready var pfx_falling = $PlayerController/NoRotateBall/PfxFallingIndicator
@onready var pfx_bodyfall = $PlayerController/UpperBody/PfxBodyfall

#--------------- Settings -----------------------------------------------------
var fallStartPoint = 0.2
var fallNoRecoverPoint = 0.6
var DrunkCost_Roll = -1.0
var DrunkCost_HitFurniture = -0.1


#------------------------------------------------------------------------------
### statess 
enum MoveStates {STANDUP, MOVING, FALLING, ROLLING, FLASKY, FELL}
enum HandStates {DANGLY, REACHING, HOLD, DRINKING, ROLLING, FIXED}
enum FeetStates {IK, REACHING, HOLD, DRINKING, ROLLING, FIXED}

# input states
var grabbingL = false
var grabbingR = false

# move state
var inMoveState = MoveStates.MOVING
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


#----------------------------------------
func _ready() -> void:
	# need to set these from here as they might not exist in the body when its ready
	$PlayerBody.player_rb = $PlayerController/RigidBally3D
	$PlayerBody.rb_arm_l = $PlayerController/ArmL
	$PlayerBody.rb_arm_r = $PlayerController/ArmR
	$PlayerBody.upper_body = $PlayerController/UpperBody
	$PlayerBody.body_attach_point = $PlayerController/UpperBody/BodyAttachPoint

func goRoll() -> void:
	$PlayerController.executeRoll()
	setMoveState(MoveStates.ROLLING)
	
func riseAndShine() -> void:
	$PlayerController.standUp()
	setMoveState(MoveStates.STANDUP)
	
func setHandLState(state: HandStates):
	HandLState = state
	self.ChangeHandLeft.emit(state)

func setHandRState(state: HandStates):
	HandRState = state
	self.ChangeHandRight.emit(state)

func setMoveState(state: MoveStates):
	inMoveState = state
	self.ChangeMovement.emit(state)

func checkFalling() -> void:
	if leaning > fallNoRecoverPoint:
		setMoveState(MoveStates.FELL)
	elif leaning > fallStartPoint:
		if inMoveState != MoveStates.FALLING:
			setMoveState(MoveStates.FALLING)
	elif inMoveState != MoveStates.MOVING:
		setMoveState(MoveStates.MOVING)


func _process(_delta: float) -> void:
	# state machine
	match inMoveState:
		MoveStates.MOVING:
			checkFalling()
		MoveStates.FALLING: #FALLING
			checkFalling()
		_: pass
	
	match HandLState:
		1: pass


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
		match inMoveState:
			MoveStates.FALLING: goRoll()
			MoveStates.FELL: riseAndShine()
	

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

func _on_change_movement(state: Player.MoveStates) -> void:
	# stateTransitions
	# --- Particles
	match state:
		MoveStates.ROLLING:
			GameStateManager.player_drunkness.current_drunkness += DrunkCost_Roll
	
	match state:
		MoveStates.FALLING: pfx_falling.set_emitting(true)
		_: pfx_falling.set_emitting(false)

	match state:
		MoveStates.FELL: pfx_bodyfall.set_emitting(true)
		_: pfx_bodyfall.set_emitting(false)	
