extends StaticBody3D
class_name FurniturePlayerCollider

signal on_collided_with()

@export var wobblable := true
@export_range(0.0, 45.0) var wobble_angle := 15.0
@export var wobble_time := 1.0

var wobble_strength := 0.0

@onready var ramming_tween : Tween

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(4, true)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)


func _process(_delta: float) -> void:
	
	if not wobblable:
		return
	if not ramming_tween:
		return
	elif not ramming_tween.is_running():
		return
	
	var sine_scale := 0.01
	var rotation_max := deg_to_rad(wobble_angle)
	
	# Adjust the beginning of the wobble to prevent props flying off and shelves devouring the player.
	var less_agressive_wobble_strength := wobble_strength
	if wobble_strength > 0.975:
		less_agressive_wobble_strength = remap(
			less_agressive_wobble_strength,
			0.975,
			1.0,
			0.9,
			0.0
		)
	#print("less_agressive_wobble_strength = " + str(less_agressive_wobble_strength))
	
	var current_rotation := (
		rotation_max
		* less_agressive_wobble_strength
		* (sin(Time.get_ticks_msec() * sine_scale))
	)
	
	rotation.x = current_rotation


func on_player_collision(collision_velocity : Vector3) -> void:
	
	on_collided_with.emit()
	
	if ramming_tween:
		if ramming_tween.is_running():
			return
	
	# NOTE: This doesn't take the direction into account where the character is moving towards.
	if collision_velocity.length() < 1.0:
		return
	
	wobble_strength = 1.0
	
	ramming_tween = get_tree().create_tween()
	#ramming_tween.set_trans(Tween.TRANS_QUART)
	ramming_tween.set_ease(Tween.EASE_OUT)
	ramming_tween.tween_property(self, "wobble_strength", 0.0, wobble_time)
	
	play_wobble_sound()
	
	
func play_wobble_sound() -> void:
	var sound_player : AudioStreamPlayer3D = AudioManager.sfx_manager.get_item()
	sound_player.stream = AudioManager.sfx_manager.wobble_sounds
	sound_player.position = self.global_position
	sound_player.play()
