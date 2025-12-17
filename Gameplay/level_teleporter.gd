extends Area3D
class_name LevelTeleporter

@export var teleport_position: Node3D

func _ready() -> void:
	area_entered.connect(teleport)
	
func teleport(area: Area3D) -> void:
	if area is PlayerDetector:
		print("DETECTED")
