extends Node3D

@onready var world_environment : WorldEnvironment = $WorldEnvironment

var firstCam = true

func _ready() -> void:
	world_environment.environment.fog_enabled = true
	$CameraEnter.viewThis()


func _on_enter_camera_trigger_body_exited(body: Node3D) -> void:
	if body is RigidBally and firstCam:
		$CameraEnter.stopView()
		firstCam = false 
