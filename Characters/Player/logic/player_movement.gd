extends RigidBody3D

#----------------Settings-----------------------

static var move_force_multiplier = 100.0 # phys impulse scale
static var player_input_strength = 1.0 # how much player has control
static var player_turn_speed = 2.0 # how fast character should turn
static var drunk_input_strength = 1.0
static var drunk_chaos_speed = 1.0 # how fast drunk changes direction
static var drunk_chaos_strength = 0.2 # how strong is drunk input
static var drunk_fall_factor = 4.0 #how fast the falling will escalate

#----------------State-----------------------

var drunk_noise_vector = Vector2(0,0)
var drunk_amount = 0.0
var player_move_dir = Vector2(0,0)
var player_speed = 0.0
var player_facing_dir = Vector2(0,1.0)
var leaning = 0.0


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

func update_rotation(delta) -> void:
	if player_speed > 0.3:
		player_facing_dir = lerp(player_facing_dir, player_move_dir, player_turn_speed*delta).normalized()

func updateDebugHelpers(playerInputDir):
	$up_aligned/helper_player_dir.position = Vector3(playerInputDir.x,-0.21,playerInputDir.y)
	$up_aligned/helper_drunk_dir.position = Vector3(drunk_noise_vector.x,-0.21,drunk_noise_vector.y)
	$up_aligned/helper_player_facing.position = Vector3(player_facing_dir.x,-0.20,player_facing_dir.y)

#----------------Process-------

func _process(delta: float) -> void:
	update_body_pose(delta)
	$up_aligned/helper_leaning.position = Vector3(player_move_dir.x,-0.22,player_move_dir.y)

func _physics_process(delta: float) -> void:
	update_vectors()
	update_drunk_vector(delta)
	update_rotation(delta)
	# `velocity` will be a Vector2 between `Vector2(-1.0, -1.0)` and `Vector2(1.0, 1.0)`
	var playerInputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	var move_force = playerInputDir * player_input_strength
	move_force += drunk_noise_vector * drunk_input_strength
	move_force *= delta * move_force_multiplier
	var impulse = Vector3(move_force.x, 0, move_force.y)
	
	updateDebugHelpers(playerInputDir)
	self.apply_central_impulse(impulse)
	
	var body_offset = self.global_position - $"../UpperBody".global_position
	body_offset.y = 0.0
	body_offset = body_offset * 1.5
	
	$"../UpperBody".apply_impulse(body_offset)
	
	
