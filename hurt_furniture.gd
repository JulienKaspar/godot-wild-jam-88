extends Area3D
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
		var vector_to_player: Vector3 =GameStateManager.current_player.get_ball().global_position - global_position
		var vector_normalized: Vector3 = vector_to_player.normalized()
		GameStateManager.current_player.get_ball().linear_velocity = Vector3(0,0,0)
		GameStateManager.current_player.get_ball().apply_impulse(Vector3(
			vector_normalized.x * force_multiplier,	
			0,
			vector_normalized.z * force_multiplier))
		
		
		GameStateManager.player_drunkness.current_drunkness -= drunkness_pentalty
		AudioManager.player_sounds.play_voice(AudioManager.player_sounds.hurt_sounds)
		
		time_since_last_triggered = 0
