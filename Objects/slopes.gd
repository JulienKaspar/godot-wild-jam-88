extends StaticBody3D
class_name Slope

var collision_layers := [8]

func _ready() -> void:
	for idx in range(1, 32):
		set_collision_layer_value(idx, false)
		set_collision_mask_value(idx, false)
	
	for idx in collision_layers:
		set_collision_layer_value(idx, true)
