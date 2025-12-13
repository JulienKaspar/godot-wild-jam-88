extends Node3D

@onready var player_armature: Node3D = $PlayerBody/PlayerArmature
@onready var upper_body_pivot: Node3D = $PlayerController/RigidBally3D/upper_body_pivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_armature.global_transform = upper_body_pivot.global_transform
