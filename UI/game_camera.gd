extends Camera3D
class_name GameCamera

@export var follow_distance: float = 5
var follow_target: Node3D
var interestingCam: Camera3D
var isInterested = false
var blendingLerp = 0.0
var shakeAngleX = 0.0
var shakeStrength = 1.2

func _ready() -> void:
	GameStateManager.game_camera = self

func _physics_process(_delta: float) -> void:
	if follow_target == null: return
	var newPos = follow_target.global_position
	newPos += Vector3(0, follow_distance, follow_distance)
	position = lerp(position, newPos, 0.4)
	look_at(follow_target.global_position)
	if isInterested:
		global_transform = lerp(global_transform, interestingCam.global_transform, blendingLerp)
	applyShake(shakeStrength * UserSettings.camera_shake_modifier)

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
	blendingLerp = 0.0

func shake(intensity: float) -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "shakeAngleX", shakeAngleX + PI, 0.8)

func applyShake(multiplier: float) -> void:
	self.global_rotation_degrees.x += sin(shakeAngleX)
