extends RayCast3D
class_name StairsRayCast


func is_colliding_with_stairs() -> bool:
	
	if not is_colliding():
		return false
	
	if get_collider() is not Slope:
		return false
	
	return true
