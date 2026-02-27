extends Path3D
class_name TouchyCurve

@export var Slideable: bool = false

var bBox: AABB

func getClosestPoint(refPoint: Vector3) -> Vector3:
	return self.curve.get_closest_point(refPoint)


func computeFastCurveAABB(path: Path3D, margin: float) -> AABB:
#	just check the points and add some margin, use when dont need to be accurate
	var b: AABB
	var halfMargin = Vector3(margin,margin,margin) * 0.5
	
	for i in path.curve.point_count:
		b = b.expand(path.curve.get_point_position(i) + path.global_position)

	b = b.expand(b.position + b.size + halfMargin)
	b = b.expand(b.position - halfMargin)
	
	return b


func _ready() -> void:
	bBox = computeFastCurveAABB(self, 1.0)
	
