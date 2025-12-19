extends Area3D

@export var indie_ball : RigidBody3D


func _ready() -> void:
	body_entered.connect(on_trap_triggered)


func on_trap_triggered(body : Node3D) -> void:
	indie_ball.freeze = false
