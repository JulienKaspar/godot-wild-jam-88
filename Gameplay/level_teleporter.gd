extends Area3D
class_name LevelTeleporter

@export var teleport_position: Node3D

func _ready() -> void:
	body_entered.connect(handle_body_entered)

func handle_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		GameStateManager.move_player_and_reset.emit(teleport_position)
