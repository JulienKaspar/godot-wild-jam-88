extends Area3D
class_name PushyTeen

signal space_was_invaded()

@export var force_multiplier: float = 100.0
@export var drunkness_pentalty: float = 0.15
const cooldown: float = 2
var time_since_last_triggered: float = 0

func _ready() -> void:
	body_entered.connect(handle_collision)

func _process(delta: float) -> void:
	time_since_last_triggered += delta

func handle_collision(body : Node3D) -> void:
	
	if body is not RigidBally:
		return
	
	var impact_speed : float = GameStateManager.current_player.player_speed
	var minmum_impact_speed := 1.8
	if impact_speed < minmum_impact_speed:
		return
	
	if time_since_last_triggered > cooldown:
		PlayerMovementUtils.force_ball_away(global_position, force_multiplier)	
		GameStateManager.player_drunkness.current_drunkness -= drunkness_pentalty
		
		time_since_last_triggered = 0
		
		space_was_invaded.emit()
