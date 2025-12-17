extends Node3D
class_name HurtFurniture

@export var force_multiplier: float = 50
@export var drunkness_pentalty: float = 1
const max_parent_check_depth: int = 3
const cooldown: float = 1
var time_since_last_triggered: float = 0

func _ready() -> void:
	get_parent().on_collided_with.connect(handle_collision)
func _process(delta: float) -> void:
	time_since_last_triggered += delta

func handle_collision() -> void:
	if time_since_last_triggered > cooldown:
		PlayerMovementUtils.force_ball_away(global_position, force_multiplier)	
		GameStateManager.player_drunkness.current_drunkness -= drunkness_pentalty
		
		time_since_last_triggered = 0
