@tool
extends PlayerDetector
class_name AchievementArea

@export var achievement_to_grand_id: Achievement.ID

func handle_player_entered(_player: Node3D) -> void:
	AchievementSystem.unlock_achievement(achievement_to_grand_id)
