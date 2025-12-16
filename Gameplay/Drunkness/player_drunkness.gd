extends RefCounted
class_name PlayerDrunkness

var min_drunkness: float = 0
var max_drunkness: float = 10
var starting_drunkness: float = 5
var drunkness_decay_per_second: float = 0.1

signal on_drunkness_changed(new_value: float)

# for handling game over presumably
signal on_sobriety() 
signal on_too_drunk()

var current_drunkness: float: 
	set(value):
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
	
func _init() -> void:
	current_drunkness = starting_drunkness
	

func _on_player_consumed_drunkness(value: float) -> void:
	set_drunkness(current_drunkness + value)
