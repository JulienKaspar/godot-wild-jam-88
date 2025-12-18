extends Node3D
class_name PlayerController

@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

@export var DebugDraw = false
@export var DebugStats =  false
@onready var PlayerBodyCollider = %UpperBody
@onready var PlayerBallCollider = $RigidBally3D
@onready var PlayerRoot = $"../"
@onready var StairsRay = $NoRotateBall/StairsRay

@onready var debugHelpers = [%RigidBally3D,	$UpperBody/helper_body_col,	%ArmL,	
				%ArmR,	$LegL,	$LegR]
	
#---------------- Movement Settings -----------------------
static var player_input_strength = 1.0 # how much player has control
static var player_turn_speed = 2.0 # how fast character should turn
static var drunk_input_strength = 1.0 # how much drunk has control
static var drunk_chaos_speed = 1.0 # how fast drunk changes direction
static var drunk_chaos_strength = 0.2 # how strong is drunk input
static var drunk_fall_factor = 4.0 #how fast the falling will escalate
static var min_speed_to_turn = 0.35 #at what velocity should player start turning
static var refUpVector = Vector3(0,1,0)

#---------------- Physic Settings -------------------------
static var move_force_multiplier = 100.0 # phys impulse scale
static var upper_body_stiffness = 1.5 # scales impulse to bring body back to target
static var body_leaning_force = 0.1 # how much move direction is added to pose correction
static var stair_up_impulse = 300 # how much force should be added to go up stairs
 

#---------------- State -----------------------------------
#need to update these properly for when player spawns at not 0
@onready var player_facing_dir = Vector2(0, 0)
@onready var player_global_pos = Vector3(0,0,0)
@onready var player_global_mass_pos = Vector3(0,0,0)

var upper_body_stiffness_current = upper_body_stiffness
var drunk_noise_vector = Vector2(0,0)
var player_move_dir = Vector2(0,0)
var player_speed = 0.0
var leaning = 0.0
var isOnStairs = false

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
	var new_noise = Vector2(randf() - 0.5,randf() - 0.5)
	drunk_noise_vector += player_move_dir * delta * drunk_fall_factor
	drunk_noise_vector = lerp(drunk_noise_vector, new_noise, drunk_chaos_strength)
	

func update_body_pose(_delta) -> void:
	var angle = atan2(player_facing_dir.x, player_facing_dir.y)
	%up_aligned.global_rotation = Vector3(0,0,0)
	%upper_body_pivot.global_rotation = Vector3(0,angle,0)

func update_vectors() -> void:
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
	
func sendStatsToPlayer() -> void:
	PlayerRoot.player_speed = player_speed
	PlayerRoot.player_move_dir = player_move_dir
	PlayerRoot.player_facing_dir = player_facing_dir
	PlayerRoot.leaning = leaning
	PlayerRoot.player_global_pos = player_global_mass_pos
	PlayerRoot.player_global_mass_pos = player_global_mass_pos

func check_furniture_contact() -> void:
	for body in PlayerBallCollider.get_colliding_bodies():
		if body is FurniturePlayerCollider:
			body.on_player_collision(PlayerBallCollider.linear_velocity)

func executeRoll() -> void:
	$"AnimationPlayer".play("roll")
	$"TimerRoll".start()

func standUp() -> void:
	PlayerBodyCollider.apply_impulse(Vector3(0,7,0))
	keepUpright = true

#----------------Process--------------------------------------------------------
#-------------------------------------------------------------------------------
func _ready() -> void:
	StairsRay.target_position.y = -0.5
	if DebugDraw:
		showHelpers()
	else:
		hideelpers()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_DrawHelpers"):
		toggleDebugDraw()
	if event.is_action_pressed("debug_drawStats"):
		toggleDebugStats()

		
func _process(delta: float) -> void:
	update_body_pose(delta)	
	# ------------- Debug ----------------------------

	%up_aligned/helper_leaning.position = Vector3(player_move_dir.x,-0.22,player_move_dir.y)

func pushBody(delta: float) -> void:
		# -------- push upper body ----------
	var body_offset = PlayerBallCollider.global_position - PlayerBodyCollider.global_position
	body_offset.y = 0.0
	body_offset.x += player_move_dir.x * body_leaning_force
	body_offset.z += player_move_dir.y * body_leaning_force
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

func pushBally(delta: float, playerInputDir) -> void:
	if isOnStairs: moveUpForce = stair_up_impulse * delta
	else: moveUpForce = 0.0
	
	var move_force = playerInputDir * player_input_strength
	move_force += drunk_noise_vector * drunk_input_strength
	move_force *= delta * move_force_multiplier
	var impulse = Vector3(move_force.x, moveUpForce, move_force.y)
	PlayerBallCollider.apply_central_impulse(impulse)

func _physics_process(delta: float) -> void:
	# -------- player input ------------
	var playerInputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# stairs check
	var normalInput = playerInputDir.normalized()
	StairsRay.target_position.x = normalInput.x * 0.5
	StairsRay.target_position.z = normalInput.y * 0.5
	isOnStairs = StairsRay.is_colliding()
	
	# -------- update targets ----------
	update_vectors()
	update_drunk_vector(delta)
	update_rotation(delta)
	updateDebugHelpers(playerInputDir) # can remove when shipped

	match PlayerRoot.inMoveState:
		Player.MoveStates.FELL: 
			if keepUpright:pushBody(delta)
		_:
			if keepUpright:pushBally(delta, playerInputDir)
			if keepUpright:pushBody(delta)
	
	sendStatsToPlayer()
	check_furniture_contact()

#------------------ Signals Receivers ------------------------------------------

func stateTransitionTo(_targetState: Player.MoveStates):
	pass


func _on_player_change_movement(state: Player.MoveStates) -> void:
	match state:
		Player.MoveStates.ROLLING: upper_body_stiffness_current = 10
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
