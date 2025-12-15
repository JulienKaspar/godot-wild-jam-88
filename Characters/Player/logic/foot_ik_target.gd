extends Marker3D

signal has_started_stepping()

@export var step_target: Node3D
@export var other_foot: Node3D

var step_distance: float = 0.5
var lean_distance: float = 0.2
var step_speed: float = 0.1

var check_lean: Timer

var is_stepping := false

func _ready() -> void:
	check_lean = Timer.new()
	check_lean.one_shot = true
	add_child(check_lean)

func _process(_delta: float) -> void:
	if !is_stepping && !other_foot.is_stepping:
		var lean = abs(global_position.distance_to(step_target.global_position))
		if lean > step_distance:
			step()
		# Update the feet positions every so often to make sure the body is in a stable position
		if lean > lean_distance && check_lean.is_stopped():
			step()
			check_lean.start(randf_range(0.5, 1.0))

func step():
	is_stepping = true
	has_started_stepping.emit()
	var target_pos = step_target.global_position
	var half_way = (global_position + step_target.global_position) / 2
	var high_point = owner.basis.y + Vector3(0, -0.6, 0)
	# Animate acring step
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way + high_point, step_speed)
	t.tween_property(self, "global_position", target_pos, step_speed)
	t.tween_callback(func(): is_stepping = false)
	
	
