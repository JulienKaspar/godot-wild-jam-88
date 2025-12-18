extends RefCounted
class_name PlayerMovementUtils

static func force_ball_away(position: Vector3, force_multiplier: float) -> void:
	var vector_to_player: Vector3 =GameStateManager.current_player.get_ball().global_position - position
	var vector_normalized: Vector3 = vector_to_player.normalized()
	GameStateManager.current_player.get_ball().linear_velocity = Vector3(0,0,0)
	GameStateManager.current_player.get_ball().apply_impulse(Vector3(
		vector_normalized.x * force_multiplier,
		0,
		vector_normalized.z * force_multiplier))
		
static func force_ball_towards(position: Vector3, force_multiplier: float) -> void:
	var vector_to_player: Vector3 =position - GameStateManager.current_player.get_ball().global_position
	var vector_normalized: Vector3 = vector_to_player.normalized()
	GameStateManager.current_player.get_ball().linear_velocity = Vector3(0,0,0)
	GameStateManager.current_player.get_ball().apply_impulse(Vector3(
		vector_normalized.x * force_multiplier,
		0,
		vector_normalized.z * force_multiplier))
		
static func force_body_away(position: Vector3, force_multiplier: float) -> void:
	var vector_to_player: Vector3 =GameStateManager.current_player.get_upper_body().global_position - position
	var vector_normalized: Vector3 = vector_to_player.normalized()
	GameStateManager.current_player.get_upper_body().apply_impulse(Vector3(
		vector_normalized.x * force_multiplier,
		0,
		vector_normalized.z * force_multiplier))

static func force_body_towards(position: Vector3, force_multiplier: float) -> void:
	var vector_to_player: Vector3 = position - GameStateManager.current_player.get_upper_body().global_position
	var vector_normalized: Vector3 = vector_to_player.normalized()
	GameStateManager.current_player.get_upper_body().apply_impulse(Vector3(
		vector_normalized.x * force_multiplier,
		0,
		vector_normalized.z * force_multiplier))


static func slip_player(player_position: Vector3, force_multiplier: float) -> void:
	var ball_momentum_direction: Vector3 = GameStateManager.current_player.get_ball().linear_velocity.normalized()
	force_ball_towards(player_position + ball_momentum_direction, force_multiplier)
	force_body_towards(player_position - ball_momentum_direction, force_multiplier / 3)
	
static func knock_player_down() -> void:
	GameStateManager.current_player.setMoveState(Player.MoveStates.FELL)
	force_ball_towards(GameStateManager.current_player.global_position + Vector3(1,0,1), 100)
	force_body_away(GameStateManager.current_player.global_position - Vector3(1,0,1), 200)
