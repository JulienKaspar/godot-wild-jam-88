extends Node3D
@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

signal ReachedTargetLeft(item: Object)
signal ReachedTargetRight(item: Object)
signal ConsumedLeft(item: Object)
signal ConsumedRight(item: Object)
signal FeetStateChanged(state: FeetStates, foot: Player.Hands)

enum FeetStates {FIXED, ACTIVE, MOVING_LEFT, MOVING_RIGHT, PLANTED_LEFT, PLANTED_RIGHT}

var UP = Vector3(0,1,0)
var RAYDIR = Vector3(0,0,-4)
var RAYDIR_LEG = Vector3(0,0,-2)
var ARM_LENGTH = 0.666
var FOOT_CORRECTION = Vector3(0,0.1,0)
var StepTriggerDistance = 0.37

@onready var PlayerRoot = $"../"
@onready var player_armature: Node3D = $PlayerArmature
@onready var skeleton: Skeleton3D = $PlayerArmature/Armature/Skeleton3D
@export var animation_player: AnimationPlayer
@onready var sound_effects : PlayerSounds = AudioManager.player_sounds

# hands
@onready var left_shoulder_ray: RayCast3D = $RayCastShouldderL
@onready var right_shoulder_ray: RayCast3D = $RayCastShouldderR
@onready var left_hand_target: Marker3D = $LeftHandTarget
@onready var right_hand_target: Marker3D = $RightHandTarget
@onready var drink_hole_left: Marker3D = $DrinkHoleL
@onready var drink_hole_right: Marker3D = $DrinkHoleR

#feet
@onready var left_foot_ray: RayCast3D = $LeftRayCast
@onready var right_foot_ray: RayCast3D = $RightRayCast
@export var left_foot_ik_target: Marker3D
@export var right_foot_ik_target: Marker3D
@export var left_foot_goto: Marker3D
@export var right_foot_goto: Marker3D

# ---------------------- External Targets --------------------------------------
@onready var player_rb: RigidBody3D
@onready var rb_arm_l: Node3D
@onready var rb_arm_r: Node3D
@onready var rb_leg_l: Node3D
@onready var rb_leg_r: Node3D

@onready var upper_body: RigidBody3D
@onready var body_attach_point: Node3D
@onready var pickup_radius: ShapeCast3D

var stepping := false

# ---------------------- Dynamics ----------------------------------------------
var inFeetState = FeetStates.ACTIVE
var inFeetTargeting = Player.FeetIKTargeting.STEPPING
var lastStepWas = Player.Hands.LEFT
var LeftFootGotoPos = Vector3(0,0,0)
var RightFootGotoPos = Vector3(0,0,0)
var LeftFootWasPos = Vector3(0,0,0)
var RightFootWasPos = Vector3(0,0,0)
var leftDrinkLerp = 0
var rightDrinkLerp = 0
var HoldingItemL: Object
var HoldingItemR: Object
var triggeredConsumableL = false
var triggeredConsumableR = false

var HandL_wobble = Vector3(0,0,0)
var HandR_wobble = Vector3(0,0,0)
var Head_wobble = Vector3(0,0,0)
var HandL_pick_location: Transform3D
var HandR_pick_location: Transform3D
var Leg_seperaion = 0.2
var StepHighPoint = Vector3(0, 0.3, 0)
var StepMaxAhead = 0.5
var stepLerp = 0.0

# ----------------- debug 
var debugDraw = false
@onready var debugHelpers = [$Label3D, $LeftFootIKTarget, $RightFootIKTarget, $LeftFootStepTarget,
$RightFootStepTarget, $LeftHandTarget, $RightHandTarget]

func updateDebugHelpers():
	$Label3D.look_at(GameStateManager.game_camera.global_position, UP, true)
	$Label3D.text = FeetStates.keys()[inFeetState] +  " - LastStep: "
	$Label3D.text += str(Player.Hands.keys()[lastStepWas])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_DrawIK"):
		if debugDraw:
			for helper in debugHelpers:
				helper.hide()
			debugDraw = false
		else:
			for helper in debugHelpers:
				helper.show()
			debugDraw = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Temp! Used to at least have a rest pose on the character while testing IK chains
	animation_player.current_animation = "REST"

	for helper in debugHelpers:
		helper.hide()
	debugDraw = false
	#left_foot_ik_target.has_started_stepping.connect(on_has_start_stepping)
	#right_foot_ik_target.has_started_stepping.connect(on_has_start_stepping)
	# sounds
	#left_foot_ik_target.has_finished_stepping.connect(AudioManager.player_sounds.footstep_player.play)
	#right_foot_ik_target.has_finished_stepping.connect(AudioManager.player_sounds.footstep_player.play)
	
	left_shoulder_ray.target_position = RAYDIR
	right_shoulder_ray.target_position = RAYDIR
	left_foot_ray.target_position = RAYDIR_LEG
	right_foot_ray.target_position = RAYDIR_LEG

	
func on_has_start_stepping():
	if stepping:
		return
	stepping = true
	
	
func hip_step_uptade(time):
	var starting = player_armature.position
	var target1 = starting + Vector3(0, -0.03, 0)
	var target2 = starting + Vector3(0, 0.04, 0)
	# Animate acring step
	#var t = get_tree().create_tween()
	#t.tween_property(player_armature, "position", target1, 0.2).set_ease(Tween.EASE_OUT)
	#t.tween_property(player_armature, "position", target2, 0.15)
	#t.tween_property(player_armature, "position", starting, 0.2).set_ease(Tween.EASE_OUT)
	#t.tween_callback(func(): stepping = false)

func update_step_targets():
	# prediction vectors
	var SideVector: Vector3
	SideVector.z = -PlayerRoot.player_facing_dir.x * Leg_seperaion
	SideVector.x = PlayerRoot.player_facing_dir.y * Leg_seperaion
	SideVector.y = 0.0
	
	var FwdVector: Vector3
	FwdVector.x = PlayerRoot.player_move_dir.x * 0.1
	FwdVector.z = PlayerRoot.player_move_dir.y * 0.1
	
	var left_lookat_pos = PlayerRoot.player_global_mass_pos + SideVector + FwdVector
	var right_lookat_pos = PlayerRoot.player_global_mass_pos - SideVector + FwdVector

	
	left_foot_ray.look_at(left_lookat_pos)
	right_foot_ray.look_at(right_lookat_pos)
	
	left_foot_goto.global_position = LeftFootGotoPos
	right_foot_goto.global_position = RightFootGotoPos
	
func drinkHandInterpolation(origin: Transform3D, hand: Object, target: Object, item: Object, time: float, check: bool) -> void:
	var blendTime = min(1.0, time * 4.0)
	if blendTime == 1.0:
		if not check:
			item.consume()
			if !AudioManager.player_sounds.voice_player.playing:
				AudioManager.player_sounds.play_voice(AudioManager.player_sounds.chug_sounds)
	hand.global_transform = lerp(origin, target.global_transform, blendTime)

func moveHand(ray: Object, hand: Object, target: Object, doRaycast: bool = false) -> void:

	if doRaycast:
		ray.look_at(target.pick_point.global_position)
		var rayHit = ray.get_collision_point()
		hand.global_position = lerp(hand.global_position, rayHit, 0.5)
	else:
		hand.global_position = lerp(hand.global_position, target.global_position, 0.5)

func updateClosestPos() -> void:
	pass
	

func moveFeet(activFoot: Player.Hands) -> void:
	match activFoot:
		Player.Hands.LEFT:
			var mov = lerp(LeftFootWasPos, LeftFootGotoPos, stepLerp)
			mov += StepHighPoint * sin(3.14 * stepLerp)
			left_foot_ik_target.global_position = mov
			right_foot_ik_target.global_position = RightFootWasPos
		Player.Hands.RIGHT:
			var mov =  lerp(RightFootWasPos, RightFootGotoPos, stepLerp)
			mov += StepHighPoint * sin(3.14 * stepLerp)
			right_foot_ik_target.global_position = mov
			left_foot_ik_target.global_position = LeftFootWasPos	

func moveFeetToRigidBody() -> void:
	right_foot_ik_target.global_position = lerp(right_foot_ik_target.global_position, rb_leg_r.global_position, 0.25)
	left_foot_ik_target.global_position = lerp(left_foot_ik_target.global_position, rb_leg_l.global_position, 0.25)

func updateStepLerp() -> void:
	stepLerp = ($StepInProgress.wait_time - $StepInProgress.time_left) / $StepInProgress.wait_time 

func drinkTimingUpdate(hand: Player.Hands) -> void:
	match hand:
		Player.Hands.LEFT:
			leftDrinkLerp = ($LeftDrink.wait_time - $LeftDrink.time_left) / $LeftDrink.wait_time
		Player.Hands.RIGHT:
			rightDrinkLerp = ($RightDrink.wait_time - $RightDrink.time_left) / $RightDrink.wait_time
	 

func checkDistance(bone: Object, target: Object) -> bool:
	var d = (bone.global_position - target.pick_point.global_position).length() - ARM_LENGTH
	if d < PlayerRoot.PickupThreshold:
		return true
	else:
		return false

func checkStepStart(was: Vector3, isCurrent: Vector3) -> bool:
	var d = (was - isCurrent).length()
	if d > StepTriggerDistance:
		return true
	else:
		return false

func _process(delta: float) -> void:
	# Make the armature follow the physics bodies
	self.global_transform = lerp(self.global_transform, body_attach_point.global_transform, .5)

	# ---------------- HAND UPDATE ----------------
	# add .pick_point when targeting drunk itemas
	match PlayerRoot.HandLState:
		Player.HandStates.REACHING:
			if PlayerRoot.closestLeft:	
				moveHand(left_shoulder_ray, left_hand_target, PlayerRoot.closestLeft, true)
				if checkDistance(left_shoulder_ray, PlayerRoot.closestLeft):
					HandL_pick_location = PlayerRoot.closestLeft.global_transform
					ReachedTargetLeft.emit(PlayerRoot.closestLeft)
			else: moveHand(left_shoulder_ray, left_hand_target, rb_arm_l)
		Player.HandStates.DRINKING:
			drinkTimingUpdate(Player.Hands.LEFT)
			drinkHandInterpolation(HandL_pick_location, left_hand_target, drink_hole_left, PlayerRoot.holdingLeft, leftDrinkLerp, triggeredConsumableL)
		_: moveHand(left_shoulder_ray, left_hand_target, rb_arm_l)
			
	match PlayerRoot.HandRState:
		Player.HandStates.REACHING: 
			if PlayerRoot.closestRight: 
				moveHand(right_shoulder_ray, right_hand_target, PlayerRoot.closestRight, true)
				if checkDistance(left_shoulder_ray, PlayerRoot.closestRight):
					HandR_pick_location = PlayerRoot.closestRight.global_transform
					ReachedTargetRight.emit(PlayerRoot.closestRight, )
			else: moveHand(right_shoulder_ray, right_hand_target, rb_arm_r)
		Player.HandStates.DRINKING:
			drinkTimingUpdate(Player.Hands.RIGHT)
			drinkHandInterpolation(HandR_pick_location, right_hand_target, drink_hole_right, PlayerRoot.holdingRight, rightDrinkLerp, triggeredConsumableR)
		_: moveHand(right_shoulder_ray, right_hand_target, rb_arm_r)
	
	# ---------------- FEET UPDATE ----------------
	match PlayerRoot.inFeetState:
		Player.FeetIKTargeting.RIGIDBODY:
			moveFeetToRigidBody()
		Player.FeetIKTargeting.STEPPING:
			match inFeetState:
				FeetStates.FIXED: pass
				FeetStates.ACTIVE: 
					update_step_targets()
					match lastStepWas:
						Player.Hands.LEFT: 
							if checkStepStart(RightFootWasPos, RightFootGotoPos):
								setFeetState(FeetStates.MOVING_RIGHT, Player.Hands.RIGHT)
							elif checkStepStart(LeftFootWasPos, LeftFootGotoPos):
								setFeetState(FeetStates.MOVING_LEFT, Player.Hands.LEFT)
						Player.Hands.RIGHT: 
							if checkStepStart(LeftFootWasPos, LeftFootGotoPos):
								setFeetState(FeetStates.MOVING_LEFT, Player.Hands.LEFT)
							elif checkStepStart(RightFootWasPos, RightFootGotoPos):
								setFeetState(FeetStates.MOVING_RIGHT, Player.Hands.RIGHT)
				FeetStates.MOVING_LEFT:
					updateStepLerp()
					hip_step_uptade(stepLerp)
					moveFeet(Player.Hands.LEFT)
				FeetStates.MOVING_RIGHT: 
					updateStepLerp()
					hip_step_uptade(stepLerp)
					moveFeet(Player.Hands.RIGHT)
				FeetStates.PLANTED_LEFT: pass
				FeetStates.PLANTED_RIGHT: pass
	#move feet targets
	if debugDraw: updateDebugHelpers()
	
func _physics_process(delta: float) -> void:
	LeftFootGotoPos = left_foot_ray.get_collision_point() + FOOT_CORRECTION
	RightFootGotoPos = right_foot_ray.get_collision_point() + FOOT_CORRECTION

func _on_player_change_feet(state: Player.FeetIKTargeting) -> void:
	match state:
		Player.FeetIKTargeting.STEPPING: pass
		Player.FeetIKTargeting.RIGIDBODY: pass

func setFeetState(state: FeetStates, foot: Player.Hands):
	inFeetState = state
	self.FeetStateChanged.emit(state, foot)

func _on_step_in_progress_timeout() -> void:
	match inFeetState:
		FeetStates.MOVING_LEFT: 
			LeftFootWasPos = LeftFootGotoPos
			setFeetState(FeetStates.PLANTED_LEFT, Player.Hands.LEFT)
		FeetStates.MOVING_RIGHT: 
			RightFootWasPos = RightFootGotoPos
			setFeetState(FeetStates.PLANTED_RIGHT, Player.Hands.RIGHT)

func _on_feet_state_changed(state: int, foot: Player.Hands) -> void:
	match state:
		FeetStates.FIXED: $StepInProgress.stop()
		FeetStates.ACTIVE: pass
		FeetStates.MOVING_LEFT: $StepInProgress.start()
		FeetStates.MOVING_RIGHT: $StepInProgress.start()
		FeetStates.PLANTED_LEFT:
			$StepInProgress.wait_time = randf_range(0.15, 0.2)
			setFeetState(FeetStates.ACTIVE, foot)
			lastStepWas = foot
		FeetStates.PLANTED_RIGHT:
			$StepInProgress.wait_time = randf_range(0.15, 0.2)
			setFeetState(FeetStates.ACTIVE, foot)
			lastStepWas = foot

func _on_left_drink_timeout() -> void:
	ConsumedLeft.emit(PlayerRoot.holdingLeft)

func _on_right_drink_timeout() -> void:
	ConsumedRight.emit(PlayerRoot.holdingRight)

func _on_player_change_hand_right(state: Player.HandStates, item: Object) -> void:
	match state:
		Player.HandStates.DRINKING:
			triggeredConsumableR = false 
			%RightDrink.start()

func _on_player_change_hand_left(state: Player.HandStates, item: Object) -> void:
	match state:
		Player.HandStates.DRINKING:
			triggeredConsumableL = false
			%LeftDrink.start()
