extends Node3D

@warning_ignore_start('unused_signal')
@warning_ignore_start('unused_variable')
@warning_ignore_start('unused_parameter')

@export var playerBody: Node3D 


#object
var inRangeLeft = []
var inRangeRight = []
var ItemsinReachLeft = false
var ItemsinReachRight = false

var NeedsSortLeft = true
var NeedsSortRight = true

#touchpoints
var inRangeTouch = []
var touchPoint: Vector3
var touchPointValid = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func getClosestPickup(inRange: Array, side:  Player.Sides ) -> Object:
	var shortestDist = 50.0
	var currentDist = 0.0
	var closestObject: Object
	var referencePoint: Vector3
	
	match side:
		Player.Sides.LEFT:
			referencePoint = $"../PlayerBody".left_shoulder_ray.global_position
		Player.Sides.RIGHT:
			referencePoint = $"../PlayerBody".right_shoulder_ray.global_position
	
	for item in inRange:
		currentDist = (item.global_position - referencePoint).length()
		if currentDist < shortestDist:
			shortestDist = currentDist
			closestObject = item
	return closestObject
	
	
func getClosestTouchPoint() -> void:
	#check all near splines for nearest point then check what is closest point
	# touchPointValid = false if no paths close
	#inRangeTouch = []
	#touchPoint: Vector3
	#touchPointValid = false
	pass

	
func getClosestHand(pos: Vector3 ) -> Vector3:
	var tPoint: Vector3
	return tPoint

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
			$"..".closestLeft = getClosestPickup(inRangeLeft, Player.Sides.LEFT)
			ItemsinReachLeft = true
	if NeedsSortRight:
		if inRangeRight.is_empty():
			$"..".closestRight = null
			ItemsinReachRight = false
		else:
			$"..".closestRight = getClosestPickup(inRangeRight, Player.Sides.RIGHT)
			ItemsinReachRight = true
	
	getClosestTouchPoint()

func _on_grab_area_left_area_entered(area: Area3D) -> void:
	if area is PickPoint:
		if not area.get_parent() in inRangeLeft:
			area.get_parent().display_prompt()
			inRangeLeft.append(area.get_parent())

func _on_grab_area_left_area_exited(area: Area3D) -> void:
	inRangeLeft.erase(area.get_parent())
	if area.get_parent() is DrunknessPickup:
		if area.get_parent() in inRangeRight: pass
		else: area.get_parent().hide_prompt()

func _on_grab_area_right_area_entered(area: Area3D) -> void:
	if area is PickPoint:
		if not area.get_parent() in inRangeRight:
			area.get_parent().display_prompt()
			inRangeRight.append(area.get_parent())
			
func _on_grab_area_right_area_exited(area: Area3D) -> void:
	inRangeRight.erase(area.get_parent())
	if area.get_parent() is DrunknessPickup:
		if area.get_parent() in inRangeLeft: pass
		else: area.get_parent().hide_prompt()


func _on_touch_area_area_entered(area: Area3D) -> void:
	if area.get_parent() is TouchyCurve:
		if not area.get_parent() in inRangeTouch:
			inRangeTouch.append(area.get_parent())


func _on_touch_area_area_exited(area: Area3D) -> void:
	inRangeTouch.erase(area.get_parent())
