extends Path3D
class_name TouchyCurve

@export var Slideable: bool = false

func getClosestPoint(refPoint: Vector3) -> Vector3:
	return self.curve.get_closest_point(refPoint)
