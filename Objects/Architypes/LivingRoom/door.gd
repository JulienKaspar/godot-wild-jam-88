extends Node3D

@onready var lamp : SpotLight3D = $SpotLight3D

@onready var original_brighness := lamp.light_energy

func _process(_delta: float) -> void:
	
	var strength := 2.0
	var sine_factor := sin(Time.get_ticks_msec() * 0.001 * strength)
	sine_factor = remap(
		sine_factor,
		-1.0,
		1.0,
		0.25,
		1.0
	)
	sine_factor = clampf(sine_factor, 0.0, 1.0)
	lamp.light_energy = original_brighness * sine_factor
