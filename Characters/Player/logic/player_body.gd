extends Node3D

@export var left_hand_target: Node3D

@export var animation_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Temp! Used to at least have a rest pose on the character while testing IK chains
	animation_player.current_animation = "REST"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
