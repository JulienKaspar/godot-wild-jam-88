extends RefCounted
class_name PlayerDrunkness

var min_drunkness: float = 0
var max_drunkness: float = 10
var starting_drunkness: float = 9
var drunkness_decay_per_second: float = 0.15
var threshold: float = 0.1
var is_resetting: bool = false
var paused: bool = false

signal on_drunkness_changed(new_value: float)

# for handling game over presumably
signal on_sobriety() 
signal on_too_drunk()

var current_drunkness: float: 
	set(value):
		var drunkness_delta = abs(current_drunkness - value)
		if drunkness_delta >= threshold and !is_resetting:
			# skip drunkness reset when out of bounds
			if current_drunkness > min_drunkness and current_drunkness < max_drunkness:
				@warning_ignore("standalone_ternary")
				drunkness_increased() if current_drunkness < value else drunkness_decreased()
		
		current_drunkness = value
		set_drunkness(value)

func set_drunkness(_new_value: float) -> void:
	on_drunkness_changed.emit(_new_value)
	if current_drunkness < min_drunkness:
		on_sobriety.emit()
		current_drunkness = min_drunkness
		return
	if current_drunkness > max_drunkness:
		on_too_drunk.emit()
		current_drunkness = max_drunkness
		return
	
func drunkness_increased() -> void:
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.drunkness_up)
	
func drunkness_decreased() -> void:
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.drunkness_down)
	
func _init() -> void:
	reset_drunkness()

func reset_drunkness() -> void:
	is_resetting = true
	current_drunkness = starting_drunkness
	is_resetting = false
