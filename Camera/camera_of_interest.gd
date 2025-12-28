extends Camera3D
class_name CameraOfInterest

@export var blendInTime = 1.0
@export var blendOutTime = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func viewThis() -> void:
	print("Uhhh, look: interesting camera:" + self.name)
	GameStateManager.game_camera.lookHere(self, blendInTime)

func stopView() -> void:
	print("Camera not interesting anymore:" + self.name)
	GameStateManager.game_camera.followPlayer(blendOutTime)
