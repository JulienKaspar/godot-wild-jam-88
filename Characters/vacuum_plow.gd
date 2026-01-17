@tool
extends Node3D

@export var plow_body : Area3D
@export var path : Path3D
@export var path_follow : PathFollow3D

@export var is_reset := true
@export var is_running := true
@export var speed := 6.0 ## Meters per second

var force_multiplier: float = 500
const cooldown: float = 1
var time_since_last_triggered: float = 0

func _ready() -> void:
	
	plow_body.body_entered.connect(handle_collision)
	
	if not path or not path_follow:
		is_reset = true


func _get_configuration_warnings():
	if not path:
		return ["Missing a Path3D node!"]
	if not path_follow:
		return ["Missing a PathFollow3D node as a child of the path!"]


func _process(delta: float) -> void:
	time_since_last_triggered += delta


func _physics_process(delta: float) -> void:
	
	if is_reset:
		plow_body.position = Vector3.ZERO
		plow_body.basis = Basis.IDENTITY
	elif is_running:
		var positive_direction : int = path_follow.use_model_front
		positive_direction = remap(positive_direction, 0, 1, -1, 1)
		path_follow.progress += speed * delta * positive_direction
		
		plow_body.global_position = path_follow.global_position
		plow_body.global_basis = path_follow.global_basis


func handle_collision(_body : Node3D) -> void:
	if time_since_last_triggered > cooldown:
		PlayerMovementUtils.force_ball_away(plow_body.global_position, force_multiplier)
		time_since_last_triggered = 0
