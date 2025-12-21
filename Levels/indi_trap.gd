extends Area3D

@export var indie_ball : RigidBody3D


func _ready() -> void:
	body_entered.connect(on_trap_triggered)


func on_trap_triggered(_body : Node3D) -> void:
	indie_ball.freeze = false
	indie_ball.body_entered.connect(keg_noise)

func keg_noise(_body) -> void:
	var sound : AudioStreamPlayer3D = AudioManager.sfx_pool.get_item()
	sound.position = indie_ball.global_position
	sound.reparent(indie_ball)
	sound.stream = AudioManager.sfx_pool.keg_sounds
	sound.play()
	print("BOOM!")
	
