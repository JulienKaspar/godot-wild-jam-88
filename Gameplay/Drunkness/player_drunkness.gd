extends RefCounted
class_name PlayerDrunkness

var min_drunkness: float = 0
var max_drunkness: float = 10
var starting_drunkness: float = 5
var drunkness_decay_per_second: float = 0.1
var threshold: float = 0.1

signal on_drunkness_changed(new_value: float)

# for handling game over presumably
signal on_sobriety() 
signal on_too_drunk()

var current_drunkness: float: 
	set(value):
		var drunkness_delta = current_drunkness - value
		if drunkness_delta >= threshold:
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
	pass
	
func drunkness_decreased() -> void:
	pass
	
func _init() -> void:
	reset_drunkness()

func reset_drunkness() -> void:
	current_drunkness = starting_drunkness
