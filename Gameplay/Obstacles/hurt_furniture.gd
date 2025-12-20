extends Node3D
class_name HurtFurniture

@onready var texture_rect_animaton: TextureRectAnimaton = %TextureRectAnimaton


@export var force_multiplier: float = 50
@export var drunkness_pentalty: float = 1
@export var visual_effect: bool = false
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
		AudioManager.player_sounds.play_voice(AudioManager.player_sounds.hurt_sounds)
		
		time_since_last_triggered = 0
		
		if visual_effect: 
			var vfx_animation: TextureRectAnimaton = texture_rect_animaton
			vfx_animation.play_frames(4)
			
