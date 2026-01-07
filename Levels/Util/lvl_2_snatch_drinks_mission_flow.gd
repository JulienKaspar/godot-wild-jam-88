extends Node3D

func _ready() -> void:
	GameStateManager.game_camera.hardFollowPlayer()
