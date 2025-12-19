extends Camera3D
class_name GameCamera

@export var follow_distance: float = 5
var follow_target: Node3D
var interestingCam: Camera3D
var isInterested = false
var blendingLerp = 0.0

func _ready() -> void:
	GameStateManager.game_camera = self

func _physics_process(_delta: float) -> void:
	if follow_target == null: return
	position = follow_target.global_position
	position += Vector3(0, follow_distance, follow_distance)
	look_at(follow_target.global_position)
	if isInterested:
		global_transform = lerp(global_transform, interestingCam.global_transform, blendingLerp)

func updateBlending() -> void:
	pass

func lookHere(cam: Camera3D, blendtime: float) -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "blendingLerp", 1.0, blendtime)
	isInterested = true
	interestingCam = cam

func followPlayer(blendtime: float):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "blendingLerp", 0.0, blendtime)
	tween.tween_property(self, "isInterested", false, blendtime)
	
func hardFollowPlayer() -> void:
	isInterested = false
