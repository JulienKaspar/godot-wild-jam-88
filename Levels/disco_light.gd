extends SpotLight3D

@onready var starting_strength := light_energy

var disco_interval := 0.4

func _process(delta: float) -> void:
	
	var time_passed := Time.get_ticks_msec() * 0.001
	var disco_modulo := fmod(time_passed, disco_interval)
	
	if disco_modulo >= disco_interval * 0.8:
		light_energy = starting_strength
	else:
		get_parent().rotate(Vector3.UP, 8.0 * delta)
		light_energy = 0.0
