extends Node3D
class_name PlayerController

@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

@export var DebugDraw = false
@export var DebugStats =  false
@onready var PlayerBodyCollider = %UpperBody
@onready var PlayerBallCollider : RigidBally = $RigidBally3D
@onready var PlayerRoot = $"../"
@onready var StairsRay = $NoRotateBall/StairsRay

@onready var debugHelpers = [%RigidBally3D,	$UpperBody/helper_body_col,	%ArmL,	
				%ArmR,	$LegL,	$LegR]
	
#---------------- Movement Settings -----------------------
static var player_input_strength = 1.0 # how much player has control
static var player_turn_speed = 2.0 # how fast character should turn
static var drunk_input_strength = 1.0 # how much drunk has control
static var drunk_chaos_speed = 1.0 # how fast drunk changes direction
static var drunk_fall_factor = 4.0 # how fast the falling will escalate
static var drunk_chaos_strength = 0.2 # how strong is drunk input
static var min_speed_to_turn = 0.35 #at what velocity should player start turning
static var refUpVector = Vector3(0,1,0)


#---------------- Physic Settings -------------------------
static var move_force_multiplier = 100.0 # phys impulse scale
static var upper_body_stiffness = 1.5 # scales impulse to bring body back to target
static var body_lean_force_move = 0.1 # move direction added to pose correction
var body_lean_force_input = 0.0 # input direction added to pose correction
static var body_lean_force_stair = 0.13 # input direction added to pose correction while on stairs
static var stair_up_impulse_idle = 4100 # force added to go up stair
static var stair_up_impulse_push = 5000 # force added to go up stair

static var stand_up_force = 7.0
static var speed_cap = 2.5
 

#---------------- State -----------------------------------
#need to update these properly for when player spawns at not 0
@onready var player_facing_dir = Vector2(0, 0)
@onready var player_global_pos = Vector3(0,0,0)
@onready var player_global_mass_pos = Vector3(0,0,0)

var player_input_lerped := 0.0 ## Factor for continuous input strength
var upper_body_stiffness_current = upper_body_stiffness
var drunk_noise_vector = Vector2(0,0)
var player_y_dir_previous : float
var player_y_dir : float
var player_move_dir_previous := Vector2.ZERO
var player_move_dir := Vector2.ZERO
var player_speed = 0.0
var leaning = 0.0
var isOnStairs = false
var stairs_normal: Vector3
var stairs_up_dir: Vector3
var stairs_side_dir: Vector3

var keepUpright = true
var moveUpForce = 0.0

# outside influence
var drunk_amount = 0.0

#----------------Utility-------

func toggleDebugDraw() -> void:
	if DebugDraw: hideelpers()
	else: showHelpers()

func toggleDebugStats() -> void:
	if DebugStats: 
		$NoRotateBall/Label3D.hide()
		DebugStats = false
	else: 
		$NoRotateBall/Label3D.show()
		DebugStats = true

func showHelpers() -> void:
	DebugDraw = true
	for helper in debugHelpers:
		helper.show()
	
func hideelpers() -> void:
	DebugDraw = false
	for helper in debugHelpers:
		helper.hide()

# generate some noise direction but tend to fall in one direction
func update_drunk_vector(delta) -> void:
	var new_noise = Vector2(randf() - 0.5, randf() - 0.5)
	drunk_noise_vector += player_move_dir * delta * drunk_fall_factor
	drunk_noise_vector = lerp(drunk_noise_vector, new_noise , drunk_chaos_strength)


func update_body_pose(_delta) -> void:
	var angle = atan2(player_facing_dir.x, player_facing_dir.y)
	%up_aligned.global_rotation = Vector3(0,0,0)
	%upper_body_pivot.global_rotation = Vector3(0,angle,0)

func update_vectors() -> void:
	player_move_dir_previous = player_move_dir
	player_y_dir_previous = player_y_dir
	player_y_dir = PlayerBallCollider.linear_velocity.y
	player_move_dir.x = PlayerBallCollider.linear_velocity.x
	player_move_dir.y = PlayerBallCollider.linear_velocity.z
	player_speed = player_move_dir.length()

	player_global_pos = PlayerBallCollider.global_position
	player_global_pos.y -= 0.25
	player_global_mass_pos = PlayerBodyCollider.global_position
	player_global_mass_pos.y = player_global_pos.y
	
	leaning =  PlayerBodyCollider.global_transform.basis.y.dot(refUpVector)
	leaning = 1 -clampf(leaning, 0, 1)

func update_rotation(delta) -> void:
	if player_speed > min_speed_to_turn:
		player_facing_dir = lerp(player_facing_dir, player_move_dir, player_turn_speed*delta).normalized()

func updateDebugHelpers(playerInputDir):
	%up_aligned/helper_player_dir.position = Vector3(playerInputDir.x,-0.21,playerInputDir.y)
	%up_aligned/helper_drunk_dir.position = Vector3(drunk_noise_vector.x,-0.21,drunk_noise_vector.y)
	%up_aligned/helper_player_facing.position = Vector3(player_facing_dir.x,-0.20,player_facing_dir.y)
	$NoRotateBall/Label3D.text = Player.MoveStates.keys()[PlayerRoot.inMoveState]
	if isOnStairs: $NoRotateBall/Label3D.text +=  " - ON STAIRS\nLeftHand: "
	else: $NoRotateBall/Label3D.text += "\nLeftHand: "
	$NoRotateBall/Label3D.text += Player.HandStates.keys()[PlayerRoot.HandLState] + "\nRightHand: "
	$NoRotateBall/Label3D.text += Player.HandStates.keys()[PlayerRoot.HandRState]
	#$NoRotateBall/helper_stairs_plane.look_at($NoRotateBall/helper_stairs_plane.global_position - stairs_normal)
	
func sendStatsToPlayer() -> void:
	PlayerRoot.player_speed = player_speed
	PlayerRoot.player_move_dir = player_move_dir
	PlayerRoot.player_facing_dir = player_facing_dir
	PlayerRoot.leaning = leaning
	PlayerRoot.player_global_pos = player_global_mass_pos
	PlayerRoot.player_global_mass_pos = player_global_mass_pos

func check_furniture_contact(body : Node3D) -> void:
	if body is FurniturePlayerCollider:
		body.on_player_collision(PlayerBallCollider.linear_velocity)

func executeRoll() -> void:
	$"AnimationPlayer".play("roll")
	$"TimerRoll".start()

func standUp() -> void:
	#if PlayerBodyCollider.global_position.y < PlayerBallCollider.global_position.y:
	var sideVec = Vector3(PlayerBodyCollider.global_position - PlayerBallCollider.global_position)
	sideVec.x = 1.0 - sideVec.x
	sideVec.z = 1.0 - sideVec.z
	sideVec.y = stand_up_force - sideVec.y
	print(sideVec)
	PlayerBodyCollider.apply_impulse(sideVec)
	#else:
	#	PlayerBodyCollider.apply_impulse(Vector3(0,stand_up_force,0))
	keepUpright = true

#----------------Process--------------------------------------------------------
#-------------------------------------------------------------------------------
func _ready() -> void:
	StairsRay.target_position.y = -0.6
	if DebugDraw:
		showHelpers()
	else:
		hideelpers()
	
	# Connect signals
	PlayerBallCollider.body_entered.connect(check_furniture_contact)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_DrawHelpers"):
		toggleDebugDraw()
	if event.is_action_pressed("debug_drawStats"):
		toggleDebugStats()

		
func _process(delta: float) -> void:
	update_body_pose(delta)	
	# ------------- Debug ----------------------------

	%up_aligned/helper_leaning.position = Vector3(player_move_dir.x,-0.22,player_move_dir.y)

func pushBody(delta: float, playerInputDir: Vector2) -> void:
	
	var stiffness_strength := 1.0
	
	if GameStateManager.MovementMode == GameStateManager.MovementModes.EXPERIMENTAL:
	
		# -------- bounce upper body after impact ----------
		var direction_shift_factor := player_move_dir.normalized().dot(player_move_dir_previous.normalized()) * -1
		direction_shift_factor = clamp(direction_shift_factor, 0.0, 1.0)
		var max_bounce_strength := 15.0
		var bounce_speed_factor := remap(
			player_move_dir_previous.length(),
			2.0,
			speed_cap,
			0.0,
			max_bounce_strength
		)
		max_bounce_strength = clamp(max_bounce_strength, 0.0, max_bounce_strength)
		direction_shift_factor *= bounce_speed_factor
		if direction_shift_factor > 0.0:
			PlayerMovementUtils.force_body_towards(
				Vector3(player_move_dir.x, 0.0, player_move_dir.y).normalized(),
				direction_shift_factor
			)
	
		if playerInputDir == Vector2.ZERO:
			stiffness_strength = lerp(0.6, 1.0, player_input_lerped)
	
	# -------- push upper body ----------
	var body_offset = PlayerBallCollider.global_position - PlayerBodyCollider.global_position
	if body_offset.y > 0.0:
		#body is below ball, fell on a slope
		body_offset *= -1.0
		body_offset.y = 50.0 * delta
	else:
		body_offset.y = 0.0
	
	# leaning from movement
	body_offset.x += player_move_dir.x * body_lean_force_move
	body_offset.z += player_move_dir.y * body_lean_force_move
	
	if isOnStairs:
		body_offset.x += playerInputDir.x * body_lean_force_stair
		body_offset.z += playerInputDir.y * body_lean_force_stair
	else:
		# leaning from input if its in the opposite direction of leaning
		var input_body_scalar := Vector2(body_offset.normalized().x, body_offset.normalized().z).dot(playerInputDir)
		input_body_scalar = max(input_body_scalar, 0.0)
		
		body_offset.x += playerInputDir.x * body_lean_force_input * input_body_scalar
		body_offset.z += playerInputDir.y * body_lean_force_input * input_body_scalar
	
	if (
		GameStateManager.MovementMode == GameStateManager.MovementModes.EXPERIMENTAL
		and upper_body_stiffness_current == upper_body_stiffness
	):
		body_offset = body_offset * (upper_body_stiffness_current * stiffness_strength)
	else:
		body_offset = body_offset * upper_body_stiffness_current
	
	PlayerBodyCollider.apply_impulse(body_offset)
	
	# -------- rotate upper body ----------
	var body_torque = Vector3(0,0,0)
	var body_fwd_dir = PlayerBodyCollider.global_transform.basis.x
	body_fwd_dir.y = 0
	body_fwd_dir = body_fwd_dir.normalized()
	
	var body_fwd_2D = Vector2(body_fwd_dir.x, body_fwd_dir.z)
	body_torque.y = body_fwd_2D.dot(player_facing_dir) * 10 * delta
	PlayerBodyCollider.apply_torque_impulse(body_torque)

func pushBally(delta: float, playerInputDir: Vector2) -> void:
	
	var move_force : Vector2
	
	# Apply input or slowly dampen movement
	if playerInputDir != Vector2.ZERO:
		move_force = playerInputDir * player_input_strength
	elif GameStateManager.MovementMode == GameStateManager.MovementModes.EXPERIMENTAL:
		var velocity := PlayerBallCollider.linear_velocity
		move_force = Vector2(velocity.x, velocity.z) * -0.3
	
	move_force += drunk_noise_vector * drunk_input_strength
	move_force *= delta * move_force_multiplier
	var impulse = Vector3(move_force.x, 0.0, move_force.y)
	
	# keep ball on stairs
	if isOnStairs:
		var input_in_stair_space = playerInputDir.dot(Vector2(stairs_up_dir.x, stairs_up_dir.z))
		var stairsScaler = lerp(stair_up_impulse_idle, stair_up_impulse_push, input_in_stair_space)
		var stair_force = stairs_up_dir * stairsScaler * delta * (1 - stairs_normal.dot(refUpVector))
		impulse += stair_force
	
	PlayerBallCollider.apply_central_impulse(impulse)
	
	if GameStateManager.MovementMode == GameStateManager.MovementModes.EXPERIMENTAL:
		# Cancel vertical bouncing after a fall
		var y_difference := player_y_dir - player_y_dir_previous
		if y_difference > 0.5:
			PlayerBallCollider.linear_velocity.y = 0.0
		
		# Max out linear velocity
		if PlayerBallCollider.linear_velocity.length() > speed_cap and not isOnStairs:
			PlayerBallCollider.linear_velocity = lerp(
				PlayerBallCollider.linear_velocity,
				PlayerBallCollider.linear_velocity.normalized() * 2.0,
				delta
			)
	

func _physics_process(delta: float) -> void:
	# -------- player input ------------
	var playerInputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Increase input strength. Controller stick is then always more aggressive. Less fine tuning in input.
	playerInputDir = playerInputDir.normalized() * (min(playerInputDir.length() * 2.0, 1.0))
	
	var lerp_strength := 5.0
	if playerInputDir == Vector2.ZERO:
		lerp_strength = 1.0
	player_input_lerped = move_toward(player_input_lerped, playerInputDir.length(), lerp_strength * delta)
	
	var cameraYRotation = GameStateManager.game_camera.global_rotation_degrees.y
	playerInputDir = playerInputDir.rotated(deg_to_rad(-cameraYRotation))

	# stairs check
	var normalInput = playerInputDir.normalized()
	StairsRay.target_position.x = normalInput.x * 0.01
	StairsRay.target_position.z = normalInput.y * 0.01
	isOnStairs = StairsRay.is_colliding()
	if isOnStairs:
		stairs_normal = StairsRay.get_collision_normal()
		stairs_side_dir = stairs_normal.cross(refUpVector)
		stairs_up_dir = stairs_side_dir.cross(stairs_normal)
	else:
		stairs_normal = refUpVector
	
	# -------- update targets ----------
	update_vectors()
	update_drunk_vector(delta)
	update_rotation(delta)
	updateDebugHelpers(playerInputDir) # can remove when shipped

	match PlayerRoot.inMoveState:
		Player.MoveStates.FELL: 
			if keepUpright:pushBody(delta, playerInputDir)
		_:
			if keepUpright:pushBally(delta, playerInputDir)
			if keepUpright:pushBody(delta, playerInputDir)
	
	particlePlacement()
	sendStatsToPlayer()

#------------------ Signals Receivers ------------------------------------------

func particlePlacement() -> void:
	$NoRotateBall/PfxFallingIndicator.global_position = player_global_mass_pos

	$NoRotateBall/PfxBodyfall.global_position = player_global_pos
	#$NoRotateBall/PfxBodyfall.global_rotation.y = atan2(player_facing_dir.x, player_facing_dir.y)
	$NoRotateBall/PfxBodyfall.look_at(player_global_mass_pos)

func stateTransitionTo(_targetState: Player.MoveStates):
	pass


func _on_player_change_movement(state: Player.MoveStates) -> void:
	match state:
		Player.MoveStates.ROLLING: upper_body_stiffness_current = 10
		Player.MoveStates.STANDUP: 
			if GameStateManager.MovementMode == GameStateManager.MovementModes.EXPERIMENTAL:
				upper_body_stiffness_current = 3.0
		_: upper_body_stiffness_current = upper_body_stiffness
		
	match state:
		Player.MoveStates.FALLING: 
			$TimerFalling.start()
			keepUpright = true
			AudioManager.player_sounds.play_voice(AudioManager.player_sounds.falling_sounds)
		Player.MoveStates.FELL: 
			keepUpright = false
			PlayerBallCollider.angular_damp = 5
			PlayerBallCollider.linear_damp = 5
		Player.MoveStates.STANDUP: 
			$TimerStandUp.start()
			standUp()
			AudioManager.player_sounds.play_voice(AudioManager.player_sounds.getting_up_sounds)
		_: 
			keepUpright = true
			$TimerFalling.stop()
			match state:
				Player.MoveStates.ROLLING:
					PlayerBallCollider.angular_damp = 1
					PlayerBallCollider.linear_damp = 1
				_:
					PlayerBallCollider.angular_damp = 0
					PlayerBallCollider.linear_damp = 0


func Reset(newpos: Vector3) -> void:
	pass
	
# ------------------ Timers ------------------------

func _on_timer_roll_timeout() -> void:
	PlayerRoot.setMoveState(Player.MoveStates.MOVING)

func _on_timer_falling_timeout() -> void:
	keepUpright = false

func _on_timer_stand_up_timeout() -> void:
	PlayerRoot.setMoveState(Player.MoveStates.MOVING)
