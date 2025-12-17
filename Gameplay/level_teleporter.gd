extends Area3D
class_name LevelTeleporter

@export var collision_shape: Shape3D


func _ready() -> void:
	area_entered.connect(teleport)
	
func teleport(area: Area3D) -> void:
	if area is PlayerDetector:
		print("DETECTED")
