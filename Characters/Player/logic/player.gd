extends Node3D
class_name Player

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
enum HandStates {DANGLY, REACHING, HOLD, DRINKING}

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

func _process(_delta: float) -> void:
	# Make the armature follow the physics bodies
	player_body.global_transform = lerp(player_body.global_transform, body_attach_point.global_transform, .5)
	left_hand_target.global_transform = lerp(left_hand_target.global_transform, rb_arm_l.global_transform, 0.5)
	right_hand_target.global_transform = lerp(right_hand_target.global_transform, rb_arm_r.global_transform, 0.5)

	update_step_targets()
	# ------- Input Handling ------
	if Input.is_action_pressed("grab_left"):
		grabbingL = true
	else:
		grabbingL = false
		
	if Input.is_action_pressed("grab_right"):
		grabbingR = true
	else:
		grabbingR = false
		
	if Input.is_action_just_pressed("roll"):
		if canRoll:
			goRoll()
		else:
			# WIP, player feedback fo unsuccessfull roll?
			pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup"):
		#replace with hand handling (haha get it)
		attempt_pickup()

func attempt_pickup() -> void:
	var items := get_pickups_in_range()
	if items.size() == 0:
		return
	
	var pickup: DrunknessPickup = items[0]
	pickup.pickup(self)

func get_pickups_in_range() -> Array[DrunknessPickup]:
	var amount_of_items_in_range: int = pickup_radius.get_collision_count()
	var items_in_range: Array[DrunknessPickup] = []
	for i in amount_of_items_in_range:
		var item = pickup_radius.get_collider(i)
		if item is DrunknessPickup:
			items_in_range.append(item)
	return items_in_range
	
func update_step_targets():
	var step_rect: Node3D = $PlayerController/RigidBally3D/step_rect
	var root_pos = player_rb.global_position + Vector3(0, -0.25, 0)
	step_rect.global_position = player_rb.global_position + Vector3(0, -0.2, 0)
	step_rect.global_rotation = Vector3(0, -atan2(player_facing_dir.y, player_facing_dir.x) + PI/2, 0)

	var balance_vec = player_global_mass_pos - root_pos
	var speed = upper_body.linear_velocity.length() * 1.5
	var left_inv_transform = player_body.global_transform.inverse().basis
	var local_balance_vec = left_inv_transform * (balance_vec * 2)
	
	left_step_target.target_position.x = local_balance_vec.x * speed
	left_step_target.target_position.z = local_balance_vec.z * speed
	
	right_step_target.target_position.x = local_balance_vec.x * speed
	right_step_target.target_position.z = local_balance_vec.z * speed
	
