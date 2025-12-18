@tool
extends Slope

@export var wall_material : Material
@export var ground_material : Material
@export var stair_asset : Node3D

func _process(_delta: float) -> void:
	for node in stair_asset.get_children():
		if node is MeshInstance3D:
			node.set_surface_override_material(0, wall_material)
			node.set_surface_override_material(2, ground_material)
