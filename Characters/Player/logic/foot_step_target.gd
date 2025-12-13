extends RayCast3D

@export var step_target: Node3D

func _physics_process(delta: float) -> void:
	global_position = owner.global_position
	var hit_point = get_collision_point()
	if hit_point:
		step_target.global_position = hit_point
