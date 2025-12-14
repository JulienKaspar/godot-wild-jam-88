extends Node3D

@onready var player_body: Node3D = $PlayerBody
@onready var step_target: Node3D = $PlayerBody/StepTarget
@onready var player_rb: Node3D = $PlayerController/RigidBally3D
@onready var upper_body_pivot: Node3D = $PlayerController/RigidBally3D/upper_body_pivot

func _physics_process(_delta: float) -> void:
	player_body.global_transform = lerp(player_body.global_transform, upper_body_pivot.global_transform, .5)
	animate_hips()
	
func animate_hips() -> void:
	player_body.position.y = sin(Time.get_ticks_msec() / float(1000) * 0.5) * 0.05
