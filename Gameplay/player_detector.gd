@tool
@abstract class_name PlayerDetector
extends Area3D



var player_detector: CollisionShape3D
const max_parent_check_depth: int = 3

@abstract func handle_player_entered(player: Node3D) -> void


func _ready() -> void:
	body_entered.connect(handle_collision)

func handle_collision(body: Node3D) -> void:
	if has_player_as_parent(body):
		handle_player_entered(body)

func _get_configuration_warnings():
	for child in get_children():
		if child is CollisionShape3D:
			return []	
			
	if player_detector == null:
		return ["Add an CollisionShape3D that checks where the Player is!"]
	
	if get_collision_mask_value(2) == false:
		return ["CollisionShape3D collision mask needs to be set to 2 to detect the player!"]

func has_player_as_parent(body: Node3D) -> bool:
	var current_node_checked: Node
	for i in max_parent_check_depth:
		@warning_ignore("unassigned_variable")
		if current_node_checked == null:
			current_node_checked = body
		
		if current_node_checked is Player:
			return true
		
		current_node_checked = current_node_checked.get_parent()
	return false
		
