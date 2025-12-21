@tool
extends LevelTeleporter

func handle_collision(body: Node3D) -> void:
	if has_player_as_parent(body):
		GameStateManager.reset_level()
