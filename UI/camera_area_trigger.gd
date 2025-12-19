extends Area3D

@export var ExitCam: CameraOfInterest
var playerInExitZone = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("body_entered", _on_body_entered)
	self.connect("body_exited", _on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBally and not playerInExitZone:
		ExitCam.viewThis()



func _on_body_exited(body: Node3D) -> void:
	if body is RigidBally:
		ExitCam.stopView()
