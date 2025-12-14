extends Camera3D
class_name GameCamera

@export var follow_distance: float = 5
@export var player: Node3D
var follow_target: Node3D

func _ready() -> void:
	follow_target = player.get_node("PlayerBody")

func _physics_process(_delta: float) -> void:
	position = follow_target.position
	position += Vector3(0, follow_distance, follow_distance)
	look_at(follow_target.position)
