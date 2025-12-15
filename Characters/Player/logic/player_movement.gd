extends RigidBody3D
class_name PlayerController

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


#---------------- State -----------------------------------

var drunk_noise_vector = Vector2(0,0)
var player_move_dir = Vector2(0,0)
var player_speed = 0.0
var player_facing_dir = Vector2(0,1.0)
var leaning = 0.0
var player_global_pos = Vector3(0,0,0)
var player_global_mass_pos = Vector3(0,0,0)

# outside influence
var drunk_amount = 0.0

#----------------Utility-------

# generate some noise direction but tend to fall in one direction
func update_drunk_vector(delta) -> void:
	var new_noise = Vector2(randf() - 0.5,randf() - 0.5)
	drunk_noise_vector += player_move_dir * delta * drunk_fall_factor
	drunk_noise_vector = lerp(drunk_noise_vector, new_noise, drunk_chaos_strength)
	

func update_body_pose(_delta) -> void:
	var angle = atan2(player_facing_dir.x, player_facing_dir.y)
	$up_aligned.global_rotation = Vector3(0,0,0)
	$upper_body_pivot.global_rotation = Vector3(0,angle,0)

func update_vectors() -> void:
	player_move_dir.x = self.linear_velocity.x
	player_move_dir.y = self.linear_velocity.z
	player_speed = player_move_dir.length()

	player_global_pos = self.global_position
	player_global_pos.y -= 0.25
	player_global_mass_pos = $"../UpperBody".global_position
	player_global_mass_pos.y = player_global_pos.y
	
	leaning =  $"../UpperBody".global_transform.basis.y.dot(refUpVector)
	leaning = 1 -clampf(leaning, 0, 1)

func update_rotation(delta) -> void:
	if player_speed > min_speed_to_turn:
		player_facing_dir = lerp(player_facing_dir, player_move_dir, player_turn_speed*delta).normalized()

func updateDebugHelpers(playerInputDir):
	$up_aligned/helper_player_dir.position = Vector3(playerInputDir.x,-0.21,playerInputDir.y)
	$up_aligned/helper_drunk_dir.position = Vector3(drunk_noise_vector.x,-0.21,drunk_noise_vector.y)
	$up_aligned/helper_player_facing.position = Vector3(player_facing_dir.x,-0.20,player_facing_dir.y)

func sendStatsToPlayer() -> void:
	$"../../".player_speed = player_speed
	$"../../".player_move_dir = player_move_dir
	$"../../".player_facing_dir = player_facing_dir
	$"../../".leaning = leaning
	$"../../".player_global_pos = player_global_mass_pos
	$"../../".player_global_mass_pos = player_global_mass_pos

func check_furniture_contact() -> void:
	for body in get_colliding_bodies():
		if body is FurniturePlayerCollider:
			body.on_player_collision(linear_velocity)

#----------------Process-------

func _process(delta: float) -> void:
	update_body_pose(delta)
	$up_aligned/helper_leaning.position = Vector3(player_move_dir.x,-0.22,player_move_dir.y)

func _physics_process(delta: float) -> void:
	# -------- player input ------------
	var playerInputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# -------- update targets ----------
	update_vectors()
	update_drunk_vector(delta)
	update_rotation(delta)
	updateDebugHelpers(playerInputDir) # can remove when shipped

	# -------- push Bally ---------------
	var move_force = playerInputDir * player_input_strength
	move_force += drunk_noise_vector * drunk_input_strength
	move_force *= delta * move_force_multiplier
	var impulse = Vector3(move_force.x, 0, move_force.y)
	self.apply_central_impulse(impulse)
	
	# -------- push upper body ----------
	var body_offset = self.global_position - $"../UpperBody".global_position
	body_offset.y = 0.0
	body_offset.x += player_move_dir.x * body_leaning_force
	body_offset.z += player_move_dir.y * body_leaning_force
	body_offset = body_offset * upper_body_stiffness
	$"../UpperBody".apply_impulse(body_offset)
	
	# -------- rotate upper body ----------
	var body_torque = Vector3(0,0,0)
	var body_fwd_dir = $"../UpperBody".global_transform.basis.x
	body_fwd_dir.y = 0
	body_fwd_dir = body_fwd_dir.normalized()
	
	var body_fwd_2D = Vector2(body_fwd_dir.x, body_fwd_dir.z)
	body_torque.y = body_fwd_2D.dot(player_facing_dir) * 10 * delta
	$"../UpperBody".apply_torque_impulse(body_torque)
	
	sendStatsToPlayer()
	check_furniture_contact()


func stateTransitionTo(targetState: Player.MoveStates):
	pass
