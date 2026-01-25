extends Node

@export var keg: RigidBody3D
var touched_keg: bool = false

func _enter_tree() -> void:
	listen_to_keg_trigger.call_deferred()

func listen_to_keg_trigger() -> void:
	keg.body_entered.connect(handle_keg_collision)
	
func handle_keg_collision(body: Node3D) -> void:
	if PlayerDetector.has_player_as_parent(body):
		AchievementSystem.unlock_achievement(Achievement.ID.DodgeKeg)
