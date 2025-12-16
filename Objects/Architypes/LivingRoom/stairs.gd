@tool
extends Slope

@export var wall_material : StandardMaterial3D
@export var stair_asset : Node3D

func _process(_delta: float) -> void:
	for node in stair_asset.get_children():
		if node is MeshInstance3D:
			node.set_surface_override_material(0, wall_material)
