@tool
extends Node3D

@export var wall_material : Material

@onready var lamp : SpotLight3D = $SpotLight3D
@onready var original_brighness := lamp.light_energy


func _ready() -> void:
	for node in get_children():
		if node is CSGBox3D:
			node.set_material(wall_material)


func _process(_delta: float) -> void:
	
	if Engine.is_editor_hint():
		for node in get_children():
			if node is CSGBox3D:
				var csg_box : CSGBox3D = node
				csg_box.set_material_override(wall_material)
	
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
