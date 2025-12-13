extends Node3D

@onready var player_body: Node3D = $PlayerBody
@onready var upper_body_pivot: Node3D = $PlayerController/RigidBally3D/upper_body_pivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	player_body.global_transform = upper_body_pivot.global_transform
