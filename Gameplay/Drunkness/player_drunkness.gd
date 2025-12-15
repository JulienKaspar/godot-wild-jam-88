extends Node
class_name PlayerDrunkness

@export var min_drunkness: float = 0
@export var max_drunkness: float = 10
@export var starting_drunkness: float = 5
@export var drunkness_decay_per_second: float = 0.1

signal on_drunkness_changed(new_value: float)

# for handling game over presumably
signal on_sobriety() 
signal on_too_drunk()


var current_drunkness: float: 
	set(value):
		current_drunkness = value
		set_drunkness(value)

func set_drunkness(_new_value: float) -> void:
	on_drunkness_changed.emit()
	if current_drunkness < min_drunkness:
		on_sobriety.emit()
		return
	if current_drunkness > max_drunkness:
		on_too_drunk.emit()
		return
	
func _ready() -> void:
	current_drunkness = starting_drunkness

func _process(delta: float) -> void:
	current_drunkness -= drunkness_decay_per_second * delta


func _on_player_consumed_drunkness(value: float) -> void:
	set_drunkness(current_drunkness + value)
