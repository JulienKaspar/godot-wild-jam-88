extends Camera3D
class_name CameraOfInterest

@export var blendInTime = 1.0
@export var blendOutTime = 5.0

	
func viewThis() -> void:
	print("Uhhh, look: interesting camera:" + self.name)
	GameStateManager.game_camera.lookHere(self, blendInTime)

func stopView() -> void:
	print("Camera not interesting anymore:" + self.name)
	GameStateManager.game_camera.followPlayer(blendOutTime)
