extends Area3D

@export var indie_ball : RigidBody3D
@export var dodge_time_for_achievement: float = 6

var time_elapsed_since_unfrozen: float = 0
var has_collided_with_player: bool = false

func _ready() -> void:
	disable_barrel()
	body_entered.connect(on_trap_triggered)
	indie_ball.body_entered.connect(keg_noise)
	
func _process(delta: float) -> void:
	if indie_ball.freeze: return
	time_elapsed_since_unfrozen += delta
	
	var enough_time_passed: bool = time_elapsed_since_unfrozen > dodge_time_for_achievement
	var achievement_already_unlocked: bool = AchievementSystem.is_achievement_already_unlocked(Achievement.ID.DodgeKeg)
	if  enough_time_passed && !achievement_already_unlocked && !has_collided_with_player:
		AchievementSystem.unlock_achievement(Achievement.ID.DodgeKeg)

func handle_keg_collision(body: Node3D) -> void:
	if PlayerDetector.has_player_as_parent(body):
		has_collided_with_player = true

func on_trap_triggered(_body : Node3D) -> void:
	roll_barrel()
	
func keg_noise(_body) -> void:
	if indie_ball.linear_velocity.length() < 0.5: return
	var sound : AudioStreamPlayer3D = AudioManager.sfx_manager.get_item()
	if !sound: return # check for sound available
	sound.position = indie_ball.global_position
	sound.reparent(indie_ball)
	sound.stream = AudioManager.sfx_manager.keg_sounds
	sound.play()
	print("BOOM!")


func disable_barrel() -> void:
	indie_ball.hide()
	indie_ball.freeze = true
	indie_ball.set_collision_layer_value(1, false)


func roll_barrel() -> void:
	indie_ball.show()
	indie_ball.freeze = false
	indie_ball.set_collision_layer_value(1, true)
