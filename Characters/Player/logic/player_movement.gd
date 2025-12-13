extends RigidBody3D

#----------------Settings-----------------------

static var move_force_multiplier = 100.0
static var player_input_strength = 1.0
static var drunk_input_strength = 1.0
static var drunk_chaos_speed = 1.0
static var drunk_chaos_strength = 0.1
static var drunk_fall_factor = 1.01 #how fast the falling will escalate

#----------------State-----------------------

var drunk_noise_vector = Vector2(0,0)
var drunk_amount = 0
var player_move_dir = Vector2(0,0)

#----------------Utility-------

# generate some noise direction but tend to fall in one direction
func update_drunk_vector(delta) -> void:
	drunk_noise_vector *= delta * drunk_fall_factor
	drunk_noise_vector.x += randf() * drunk_chaos_strength
	drunk_noise_vector.x += randf() * drunk_chaos_strength

#----------------Process-------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$upper_body_pivot.global_rotation = Vector3(0,0,0)
	

func _physics_process(delta: float) -> void:
	update_drunk_vector(delta)
	# `velocity` will be a Vector2 between `Vector2(-1.0, -1.0)` and `Vector2(1.0, 1.0)`
	var playerInputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var move_force = playerInputDir * player_input_strength
	move_force += drunk_noise_vector * drunk_input_strength
	move_force *= delta * move_force_multiplier
	var impulse = Vector3(move_force.x, 0, move_force.y)
	self.apply_impulse(impulse)
