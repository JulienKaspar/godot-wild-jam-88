@tool
extends Node3D
class_name SlipObstacle

@export var force_multiplier: float = 50

const cooldown: float = 5
var time_elapsed_since_activation: float = 100000
var player_detector: Area3D
var max_parent_check_depth: int = 3

func _get_configuration_warnings():
	for child in get_children():
		if child is Area3D:
			player_detector = child
	
	if player_detector == null:
		return ["Add an Area3D that checks where the Player is!"]
	
	if player_detector.get_collision_mask_value(2) == false:
		return ["Area3D collision mask needs to be set to 2 to detect the player!"]


func _ready() -> void:
	for child in get_children():
		if child is Area3D:
			player_detector = child
	
	if player_detector != null:
		player_detector.body_entered.connect(handle_player_collision)
	
func _process(delta: float) -> void:
	time_elapsed_since_activation += delta

func handle_player_collision(body: Node3D) -> void:
	if has_player_as_parent(body) && time_elapsed_since_activation > cooldown:
		time_elapsed_since_activation = 0
		PlayerMovementUtils.slip_player(GameStateManager.current_player.player_global_pos, force_multiplier)
	
	
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
		
