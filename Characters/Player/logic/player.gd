extends Node3D
class_name Player

@onready var player_body: Node3D = $PlayerBody
@onready var step_target: Node3D = $PlayerBody/StepTarget
@onready var player_rb: Node3D = $PlayerController/RigidBally3D
@onready var body_attach_point: Node3D = $PlayerController/UpperBody/BodyAttachPoint
@onready var pickup_radius: ShapeCast3D = $PickupRadius

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
var player_facing_dir = Vector2(0,1.0) # owned by player_controller
var leaning = 0.0 # owned by player_controller

# health and safety
var drunk_amount = 0.5

#----------------------------------------

func goRoll() -> void:
	pass

func _process(_delta: float) -> void:
	player_body.global_transform = lerp(player_body.global_transform, body_attach_point.global_transform, .5)
	
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
	return

func get_pickups_in_range() -> Array[DrunknessPickup]:
	var amount_of_items_in_range: int = pickup_radius.get_collision_count()
	var items_in_range: Array[DrunknessPickup] = []
	for i in amount_of_items_in_range:
		var item = pickup_radius.get_collider(i)
		if item is DrunknessPickup:
			items_in_range.append(item)
	return items_in_range
