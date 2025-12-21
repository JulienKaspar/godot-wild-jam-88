extends Node3D

var original_position;
var is_bent = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = $Area3D/Sprite3D.get_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_variation(tile):
	match tile:
		0:
			$Area3D/Sprite3D.region_rect = Rect2(4.7, 0, 16, 38.0)
		1:
			$Area3D/Sprite3D.region_rect = Rect2(22, 0, 16, 38.0)
		2:
			$Area3D/Sprite3D.region_rect = Rect2(38.17, 0, 16, 38.0)
		3:
			$Area3D/Sprite3D.region_rect = Rect2(52.46, 0, 16, 38.0)


func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	# Remove grass that collides with the helper shape
	if body.is_in_group("HelperShape"):
		queue_free()
		return

	if is_bent:
		return

	# Push the grass down on the ground
	$Area3D/Timer.stop()
	$Area3D/Sprite3D.axis = 1
	$Area3D/Sprite3D.billboard = 0
	$Area3D/Sprite3D.set_position(original_position + Vector3(0.0, 0.01, 0))
	# Push the grass along the direction of the colliding body
	if body.get("linear_velocity"):
		$Area3D/Sprite3D.set_rotation(Vector3(0, atan2(-body.linear_velocity.x, -body.linear_velocity.z), 0))
	is_bent = true

func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if $Area3D/Timer.is_inside_tree():
		$Area3D/Timer.start()

func _on_timer_timeout() -> void:
	# Reset to original position
	$Area3D/Sprite3D.axis = 2
	$Area3D/Sprite3D.billboard = 2
	$Area3D/Sprite3D.set_position(original_position)
	$Area3D/Sprite3D.set_rotation(Vector3(0, 0, 0))
	is_bent = false
