extends Camera3D
class_name GameCamera

enum cameraStates{FOLLOW, BLEND_IN, BLEND_OUT, INTERESTED}

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
var inState = cameraStates.FOLLOW
var fullBlendTime = 1.0

@onready var blendTimer = Timer.new()


func _ready() -> void:
	GameStateManager.game_camera = self
	blendTimer.one_shot = true
	blendTimer.autostart = false
	add_child(blendTimer)
	blendTimer.connect("timeout", _timer_finished)

func _physics_process(_delta: float) -> void:
	#updatefollowOffset() # camara clips in walls, to late to add
	if follow_target == null: return
	
	#player follow cam
	var newPos = follow_target.global_position
	newPos += Vector3(0, follow_distance, follow_distance)
	position = lerp(position, newPos, 0.4)
	look_at(follow_target.global_position + lookAtOffset)
	
	#blend into other camera
	if interestingCam and isInterested:
		match inState:
			cameraStates.INTERESTED:
				global_transform = interestingCam.global_transform
				fov = interestingCam.fov
			_:
				updateLerp()
				global_transform = lerp(global_transform, interestingCam.global_transform, blendingLerp)
	
	applyShake(shakeStrength * UserSettings.camera_shake_modifier)


func updatefollowOffset() -> void:
	if GameStateManager.current_player: 
		var movDir = GameStateManager.current_player.player_move_dir * 0.25
		followOffset.x = lerp(followOffset.x, clampf(movDir.x, -1.0, 1.0), 0.1)
		followOffset.z = lerp(followOffset.x, clampf(movDir.y, -1.0, 1.0), 0.1)

func lookHere(cam: Camera3D, blendtime: float) -> void:
	fullBlendTime = blendtime
	interestingCam = cam
	isInterested = true
	
	if blendtime == 0:
		blendTimer.stop()
		inState = cameraStates.INTERESTED
	else:
		match inState:
			cameraStates.FOLLOW:
				blendTimer.start(blendtime)
				inState = cameraStates.BLEND_IN
			cameraStates.INTERESTED:
				print("Hey, we already interested in other cam, not supported blend in new cam")
			cameraStates.BLEND_OUT:
				print("New cam requested while still blending from old, keep it slow man")
				shortenTimer(blendtime)
				blendTimer.start(blendtime)
				inState = cameraStates.BLEND_IN
			cameraStates.BLEND_IN:
				print("New cam requested while still blending into other, keep it slow man")
				shortenTimer(blendtime)
				blendTimer.start(blendtime)

func timerNormalized() -> float:
	return (blendTimer.wait_time - blendTimer.time_left) / blendTimer.wait_time 
	
func timeEased(x: float) -> float:
	#easeInOutQuad
	if x < 0.5:
		return 2 * x * x
	else:
		return 1 - pow(-2 * x + 2, 2) * 0.5

func updateLerp() -> void:
	match inState:
		cameraStates.BLEND_IN:
			blendingLerp = timeEased(timerNormalized())
		cameraStates.BLEND_OUT:
			blendingLerp = 1.0 - timeEased(timerNormalized())


func followPlayer(blendtime: float):
	fullBlendTime = blendtime
	match inState:
		cameraStates.FOLLOW:
			print("Cam already in Follow mode")
		cameraStates.INTERESTED:
			blendTimer.start(blendtime)
			inState = cameraStates.BLEND_OUT
		cameraStates.BLEND_OUT:
			shortenTimer(blendtime)
			blendTimer.start(blendtime)
		cameraStates.BLEND_IN:
			shortenTimer(blendtime)
			blendTimer.start(blendtime)
			inState = cameraStates.BLEND_OUT

func shortenTimer(blendtime: float) -> void:
	# how to hand blending while blend?
	pass
	
func _timer_finished() -> void:
	print("cam blend finished")
	match inState:
		cameraStates.BLEND_IN:
			inState = cameraStates.INTERESTED
		cameraStates.BLEND_OUT:
			inState = cameraStates.FOLLOW
			
func hardFollowPlayer() -> void:
	isInterested = false
	blendingLerp = 0.0
	fov = followFov
	inState = cameraStates.FOLLOW

func shake(intensity: float) -> void:
	var shaketween = get_tree().create_tween()
	shaketween.set_ease(Tween.EASE_OUT)
	shaketween.set_trans(Tween.TRANS_ELASTIC)
	shaketween.tween_property(self, "shakeAngleX", shakeAngleX + PI, 0.8)

func applyShake(multiplier: float) -> void:
	self.global_rotation_degrees.x += sin(shakeAngleX)
