extends Node3D

@export var left_hand_target: Node3D

@export var animation_player: AnimationPlayer

@onready var player_armature: Node3D = $PlayerArmature

@onready var left_foot_ik_target: Marker3D = $LeftFootIKTarget
@onready var right_foot_ik_target: Marker3D = $RightFootIKTarget

var stepping := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Temp! Used to at least have a rest pose on the character while testing IK chains
	animation_player.current_animation = "REST"
	
	left_foot_ik_target.has_started_stepping.connect(on_has_start_stepping)
	right_foot_ik_target.has_started_stepping.connect(on_has_start_stepping)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_has_start_stepping():
	if stepping:
		return
	stepping = true
	hip_step()
	
func hip_step():
	var starting = player_armature.position
	var target1 = starting + Vector3(0, -0.05, 0)
	var target2 = starting + Vector3(0, 0.02, 0)
	# Animate acring step
	var t = get_tree().create_tween()
	t.tween_property(player_armature, "position", target1, 0.2).set_ease(Tween.EASE_OUT)
	t.tween_property(player_armature, "position", target2, 0.15)
	t.tween_property(player_armature, "position", starting, 0.2).set_ease(Tween.EASE_OUT)
	t.tween_callback(func(): stepping = false)
	
