extends RayCast3D
class_name StairsRayCast


func is_colliding_with_stairs() -> bool:
	if not is_colliding():
		return false
	
	if get_collider() is not Slope:
		if get_collider() is SlipperySurface:
			get_collider().slide()
			return false
		else:
			return false
	

	# finding backside stair collider is easy if we limit stairs to be 45deg max!
	# invalid normal will always be > 45deg while valid stair top will be < 45deg
	var steapness = get_collision_normal().dot(Vector3(0.0, 1.0, 0.0))
	if steapness < 0.75: # 0.75=45deg
		return false

	return true
