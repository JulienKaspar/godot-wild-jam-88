@tool
extends Node3D

@export var plow_body : RigidBody3D
@export var path : Path3D
@export var path_follow : PathFollow3D

@export var is_reset := true
@export var is_running := true
@export var speed := 6.0 ## Meters per second


func _ready() -> void:
	
	if not path or not path_follow:
		is_reset = true


func _get_configuration_warnings():
	if not path:
		return ["Missing a Path3D node!"]
	if not path_follow:
		return ["Missing a PathFollow3D node as a child of the path!"]


func _physics_process(delta: float) -> void:
	
	if is_reset:
		plow_body.position = Vector3.ZERO
		plow_body.basis = Basis.IDENTITY
	elif is_running:
		path_follow.progress += speed * delta
		
		plow_body.global_position = path_follow.global_position
		plow_body.global_basis = path_follow.global_basis
	
