extends Node3D
class_name Player

@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

signal ChangeHandLeft(state: HandStates, item: Object)
signal ChangeHandRight(state: HandStates, item: Object)
signal ChangeFeet(state: FeetStates)
signal ChangeHandTargetL(trgt_left: Object, isValid: bool) # set isValid=false if theres none
signal ChangeHandTargetR(trgt_right: Object, isValid: bool) # set isValid=false if theres none
signal ChangeMovement(state: MoveStates)

#---------------- PFX ---------------------------------------------------------

@onready var pfx_falling = $PlayerController/NoRotateBall/PfxFallingIndicator
@onready var pfx_bodyfall = $PlayerController/UpperBody/PfxBodyfall

#--------------- Settings -----------------------------------------------------
var fallStartPoint = 0.2
var fallNoRecoverPoint = 0.6
var DrunkCost_Roll = -1.0
var DrunkCost_HitFurniture = -0.1
var DrunkCost_StandUp = -2.0
var PickupThreshold = 0.2

#---------------- IK ----------------------------------------------------------

var closestLeft: Object
var closestRight: Object

var holdingLeft: Object
var holdingRight: Object

#------------------------------------------------------------------------------
### statess 
enum MoveStates {STANDUP, MOVING, FALLING, ROLLING, FLASKY, FELL}
enum HandStates {DANGLY, REACHING, HOLD, DRINKING, ROLLING, FIXED}
enum FeetStates {STEPPING, HOLD, ROLLING, FIXED}
enum Hands {LEFT, RIGHT}

# input states
var grabbingL = false
var grabbingR = false

# move state
var inMoveState = MoveStates.MOVING
var inFeetState = FeetStates.STEPPING
var HandLState = HandStates.DANGLY
var HandRState = HandStates.DANGLY
var canRoll = true
var player_speed = 0.0 # owned by player_controller
var player_move_dir = Vector2(0,0) # owned by player_controller
var player_global_pos = Vector3(0,0,0) # owned by player_controller
var player_global_mass_pos = Vector3(0,0,0) # owned by player_controller
var player_facing_dir = Vector2(0,1.0) # owned by player_controller
var leaning = 0.0 # owned by player_controller

#----------------------------------------

func _ready() -> void:
	# need to set these from here as they might not exist in the body when its ready
	$PlayerBody.player_rb = $PlayerController/RigidBally3D
	$PlayerBody.rb_arm_l = $PlayerController/ArmL
	$PlayerBody.rb_arm_r = $PlayerController/ArmR
	$PlayerBody.upper_body = $PlayerController/UpperBody
	$PlayerBody.body_attach_point = $PlayerController/UpperBody/BodyAttachPoint

func get_ball() -> RigidBody3D:
	return $PlayerController/RigidBally3D

func goRoll() -> void:
	$PlayerController.executeRoll()
	setMoveState(MoveStates.ROLLING)
	
func riseAndShine() -> void:
	$PlayerController.standUp()
	setMoveState(MoveStates.STANDUP)
	
func setHandLState(state: HandStates, item: Object = null):
	HandLState = state
	self.ChangeHandLeft.emit(state, item)

func setHandRState(state: HandStates, item: Object = null):
	HandRState = state
	self.ChangeHandRight.emit(state, item)

func setMoveState(state: MoveStates):
	inMoveState = state
	self.ChangeMovement.emit(state)

func setFeetState(state: FeetStates):
	inFeetState = state
	self.ChangeFeet.emit(state)

func checkFalling() -> void:
	if leaning > fallNoRecoverPoint:
		setMoveState(MoveStates.FELL)
	elif leaning > fallStartPoint:
		if inMoveState != MoveStates.FALLING:
			setMoveState(MoveStates.FALLING)
	elif inMoveState != MoveStates.MOVING:
		setMoveState(MoveStates.MOVING)

func AttachItem(item: Object, hand) -> void:
	print(item)
	if item.drunkness_increase:
		GameStateManager.player_drunkness.current_drunkness += item.drunkness_increase
		item.queue_free()
	match hand:
		Hands.LEFT: setHandLState(HandStates.DANGLY)
		Hands.RIGHT: setHandRState(HandStates.DANGLY)
	

func _process(_delta: float) -> void:
	# state machine
	match inMoveState:
		MoveStates.MOVING:
			checkFalling()
		MoveStates.FALLING: #FALLING
			checkFalling()
		_: pass

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
		match HandRState:
			HandStates.DANGLY: setHandRState(HandStates.REACHING)
	else:
		grabbingR = false
		match HandRState:
			HandStates.REACHING: setHandRState(HandStates.DANGLY)
			HandStates.ROLLING: setHandRState(HandStates.DANGLY)
			HandStates.FIXED: setHandRState(HandStates.DANGLY)
		
	if Input.is_action_just_pressed("roll"):
		match inMoveState:
			MoveStates.FALLING: goRoll()
			MoveStates.FELL: riseAndShine()


func _on_player_body_reached_target_left(item) -> void:
	if item.get_script().get_global_name() == "DrunknessPickup":
		setHandLState(HandStates.HOLD, item)
		holdingLeft = item
	else:
		setHandLState(HandStates.FIXED)

func _on_player_body_reached_target_right(item) -> void:
	if item.get_script().get_global_name() == "DrunknessPickup":
		setHandRState(HandStates.HOLD, item)
		holdingRight = item
	else:
		setHandRState(HandStates.FIXED)

func _on_change_movement(state: Player.MoveStates) -> void:
	# stateTransitions
	# --- Particles
	match state:
		MoveStates.ROLLING:	
			GameStateManager.player_drunkness.current_drunkness += DrunkCost_Roll
		MoveStates.STANDUP:	
			GameStateManager.player_drunkness.current_drunkness += DrunkCost_StandUp
		
	match state:
		MoveStates.FALLING: pfx_falling.set_emitting(true)
		_: pfx_falling.set_emitting(false)

	match state:
		MoveStates.FELL: pfx_bodyfall.set_emitting(true)
		_: pfx_bodyfall.set_emitting(false)


func _on_change_hand_left(state: Player.HandStates, item: Object) -> void:
	match state:
		HandStates.HOLD: 
			AttachItem(item, Hands.LEFT)
		_: pass

func _on_change_hand_right(state: Player.HandStates, item: Object) -> void:
	match state:
		HandStates.HOLD:
			AttachItem(item, Hands.RIGHT)
		_: pass

func _on_change_feet(state: Player.FeetStates) -> void:
	pass # Replace with function body.
