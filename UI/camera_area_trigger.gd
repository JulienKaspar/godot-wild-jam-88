extends Area3D

@export var ExitCam: CameraOfInterest
var playerInExitZone = false
var belongsToLevel: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	belongsToLevel = GameStateManager.loading_into_level_index
	self.connect("body_entered", _on_body_entered)
	self.connect("body_exited", _on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBally and not playerInExitZone:
		if belongsToLevel == GameStateManager.loading_into_level_index:
			ExitCam.viewThis()
		else:
			print("Prevented Camera Enter Signal from older level")


func _on_body_exited(body: Node3D) -> void:
	if body is RigidBally:
		if belongsToLevel == GameStateManager.loading_into_level_index:
			ExitCam.stopView()
		else:
			print("Prevented Camera Exit Signal from older level")
