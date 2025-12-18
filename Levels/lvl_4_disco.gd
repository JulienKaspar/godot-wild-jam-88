extends Node3D

@onready var world_environment : WorldEnvironment = $WorldEnvironment

func _ready() -> void:
	world_environment.environment.fog_enabled = true
