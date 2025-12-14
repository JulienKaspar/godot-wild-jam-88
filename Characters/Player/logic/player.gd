extends Node3D
class_name Player

@onready var player_body: Node3D = $PlayerBody
@onready var step_target: Node3D = $PlayerBody/StepTarget
@onready var player_rb: Node3D = $PlayerController/RigidBally3D
@onready var upper_body_pivot: Node3D = $PlayerController/RigidBally3D/upper_body_pivot



func _physics_process(_delta: float) -> void:
	player_body.global_transform = lerp(player_body.global_transform, upper_body_pivot.global_transform, .5)

func _unhandled_input(event: InputEvent) -> void:
	#replace with hand handling (haha get it)
	if event.is_action_pressed("pickup"):
		pass
