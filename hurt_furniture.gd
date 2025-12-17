extends Area3D
class_name HurtFurniture
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@export var collision_shape: Shape3D
@export var force_multiplier: float = 50
@export var drunkness_pentalty: float = 1
const max_parent_check_depth: int = 3
const cooldown: float = 1
var time_since_last_triggered: float = 0

func _ready() -> void:
	body_entered.connect(handle_collision)
	collision_shape_3d.shape = collision_shape
	
func _process(delta: float) -> void:
	time_since_last_triggered += delta

func handle_collision(body: RigidBody3D) -> void:
	if has_player_as_parent(body) && time_since_last_triggered > cooldown:
		var vector_to_player: Vector3 =GameStateManager.current_player.get_ball().global_position.normalized() - global_position
		GameStateManager.current_player.get_ball().apply_impulse(Vector3(
			vector_to_player.x * force_multiplier,
			0,
			vector_to_player.z * force_multiplier))
		
		
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
		
