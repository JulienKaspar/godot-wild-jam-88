extends Camera3D
class_name GameCamera

@export var follow_distance: float = 5
var follow_target: Node3D
var lookAtOffset = Vector3(0, 0.8, 0) # X&Z will be set by player moving
var followOffset = Vector3(0, 0.0, 0)
var interestingCam: Camera3D
var isInterested = false
var blendingLerp = 0.0
var shakeAngleX = 0.0
var shakeStrength = 1.2
var followFov = 55
var customFov = 55

func _ready() -> void:
	GameStateManager.game_camera = self

func _physics_process(_delta: float) -> void:
	#updatefollowOffset() # camara clips in walls, to late to add
	if follow_target == null: return
	var newPos = follow_target.global_position
	newPos += Vector3(0, follow_distance, follow_distance)
	position = lerp(position, newPos, 0.4)
	look_at(follow_target.global_position + lookAtOffset)
	if interestingCam and isInterested:
		global_transform = lerp(global_transform, interestingCam.global_transform, blendingLerp)
	applyShake(shakeStrength * UserSettings.camera_shake_modifier)

func updatefollowOffset() -> void:
	if GameStateManager.current_player: 
		var movDir = GameStateManager.current_player.player_move_dir * 0.25
		followOffset.x = lerp(followOffset.x, clampf(movDir.x, -1.0, 1.0), 0.1)
		followOffset.z = lerp(followOffset.x, clampf(movDir.y, -1.0, 1.0), 0.1)

func lookHere(cam: Camera3D, blendtime: float) -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "blendingLerp", 1.0, blendtime)
	tween.tween_property(self, "fov", cam.fov, blendtime)
	isInterested = true
	interestingCam = cam

func followPlayer(blendtime: float):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "blendingLerp", 0.0, blendtime)
	tween.tween_property(self, "isInterested", false, blendtime)
	tween.tween_property(self, "fov", followFov, blendtime)

func hardFollowPlayer() -> void:
	isInterested = false
	blendingLerp = 0.0
	fov = followFov

func shake(intensity: float) -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "shakeAngleX", shakeAngleX + PI, 0.8)

func applyShake(multiplier: float) -> void:
	self.global_rotation_degrees.x += sin(shakeAngleX)
