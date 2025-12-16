extends StaticBody3D
class_name Slope

var collision_layers := [1, 8]

func _ready() -> void:
	for idx in collision_layers:
		print("setting layer true = " + str(idx))
		set_collision_layer_value(idx, true)
