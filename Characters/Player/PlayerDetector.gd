extends Area3D
class_name PlayerDetector

@export var detetection_radius: float = 2

func _process(_delta: float) -> void:
	var player_position: Vector3 = GameStateManager.current_player.player_global_pos
	var distance: float = (player_position - position).length()
	
	if distance < detetection_radius:
		print("YELL")
