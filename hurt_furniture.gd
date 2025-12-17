@tool
extends Area3D
class_name HurtFurniture

@export var force_multiplier: float = 50
@export var drunkness_pentalty: float = 1
const max_parent_check_depth: int = 3
const cooldown: float = 1
var time_since_last_triggered: float = 0
var player_detector : CollisionShape3D


func _get_configuration_warnings():
	for child in get_children():
		if child is CollisionShape3D:
			player_detector = child
	
	if player_detector == null:
		return ["Add an CollisionShape3D that checks where the Player is!"]
	
	if get_collision_mask_value(2) == false:
		return ["CollisionShape3D collision mask needs to be set to 2 to detect the player!"]


func _ready() -> void:
	for child in get_children():
		if child is Area3D:
			player_detector = child
	body_entered.connect(handle_collision)
	
func _process(delta: float) -> void:
	time_since_last_triggered += delta

func handle_collision(body: RigidBody3D) -> void:
	if has_player_as_parent(body) && time_since_last_triggered > cooldown:
		var vector_to_player: Vector3 =GameStateManager.current_player.get_ball().global_position - global_position
		var vector_normalized: Vector3 = vector_to_player.normalized()
		GameStateManager.current_player.get_ball().linear_velocity = Vector3(0,0,0)
		GameStateManager.current_player.get_ball().apply_impulse(Vector3(
			vector_normalized.x * force_multiplier,
			0,
			vector_normalized.z * force_multiplier))
		
		
		GameStateManager.player_drunkness.current_drunkness -= drunkness_pentalty
		
		time_since_last_triggered = 0
		

func has_player_as_parent(body: RigidBody3D) -> bool:
	var current_node_checked: Node
	for i in max_parent_check_depth:
		@warning_ignore("unassigned_variable")
		if current_node_checked == null:
			current_node_checked = body
		
		if current_node_checked is Player:
			return true
		
		current_node_checked = current_node_checked.get_parent()
	return false
		
