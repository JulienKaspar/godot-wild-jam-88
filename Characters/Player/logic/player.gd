extends Node3D
class_name Player

@onready var player_body: Node3D = $PlayerBody
@onready var step_target: Node3D = $PlayerBody/StepTarget
@onready var player_rb: Node3D = $PlayerController/RigidBally3D
@onready var upper_body_pivot: Node3D = $PlayerController/RigidBally3D/upper_body_pivot
@onready var pickup_radius: ShapeCast3D = $PickupRadius


func _physics_process(_delta: float) -> void:
	player_body.global_transform = lerp(player_body.global_transform, upper_body_pivot.global_transform, .5)

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
