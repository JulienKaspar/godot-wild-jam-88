extends Camera3D
class_name GameCamera

@export var follow_distance: float = 5
var follow_target: Node3D

func _ready() -> void:
	GameStateManager.game_camera = self

func _physics_process(_delta: float) -> void:
	if follow_target == null: return
	position = follow_target.global_position
	position += Vector3(0, follow_distance, follow_distance)
	look_at(follow_target.global_position)
