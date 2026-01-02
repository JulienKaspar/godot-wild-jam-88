@tool
extends PlayerDetector
class_name LevelTeleporter

func handle_player_entered(_body: Node3D) -> void:
	LevelLoader.next_level()
