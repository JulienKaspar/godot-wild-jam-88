extends Marker3D

@export var step_target: Node3D

@export var other_foot: Node3D

const step_distance: float = 1.0
const step_speed: float = 0.1

var is_stepping := false

func _process(delta: float) -> void:
	if !is_stepping && !other_foot.is_stepping && abs(global_position.distance_to(step_target.global_position)) > step_distance:
		step()

func step():
	is_stepping = true
	var target_pos = step_target.global_position
	var half_way = (global_position + step_target.global_position) / 2
	
	# Animate acring step
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way + owner.basis.y, step_speed)
	t.tween_property(self, "global_position", target_pos, step_speed)
	t.tween_callback(func(): is_stepping = false)
	
	
