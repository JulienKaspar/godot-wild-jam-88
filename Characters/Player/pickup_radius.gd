extends Node3D

@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

#object
var inRangeLeft = []
var inRangeRight = []
var ItemsinReachLeft = false
var ItemsinReachRight = false

var NeedsSortLeft = true
var NeedsSortRight = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func getClosest(inRange: Array) -> Object:
	var shortestDist = 50.0
	var currentDist = 0.0
	var closestObject: Object
	for item in inRange:
		currentDist = (item.global_position - $"..".player_global_pos).length()
		if currentDist < shortestDist:
			shortestDist = currentDist
			closestObject = item
	return closestObject
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.global_position = $"..".player_global_pos
	self.global_rotation.y = atan2($"..".player_facing_dir.x, $"..".player_facing_dir.y)

func _physics_process(delta: float) -> void:
	if NeedsSortLeft:
		if inRangeLeft.is_empty():
			$"..".closestLeft = null
			ItemsinReachLeft = false
		else:
			$"..".closestLeft = getClosest(inRangeLeft)
			ItemsinReachLeft = true
	if NeedsSortRight:
		if inRangeRight.is_empty():
			$"..".closestRight = null
			ItemsinReachRight = false
		else:
			$"..".closestRight = getClosest(inRangeRight)
			ItemsinReachRight = true

func _on_grab_area_left_area_entered(area: Area3D) -> void:
	if area.get_parent().get_script().get_global_name() == "DrunknessPickup":
		if not area.get_parent() in inRangeLeft:
			inRangeLeft.append(area.get_parent())

func _on_grab_area_left_area_exited(area: Area3D) -> void:
	inRangeLeft.erase(area.get_parent())

func _on_grab_area_right_area_entered(area: Area3D) -> void:
	if area.get_parent().get_script().get_global_name() == "DrunknessPickup":
		if not area.get_parent() in inRangeRight:
			inRangeRight.append(area.get_parent())
			
func _on_grab_area_right_area_exited(area: Area3D) -> void:
	inRangeRight.erase(area.get_parent())
