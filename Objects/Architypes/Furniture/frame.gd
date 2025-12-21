@tool
extends Node3D

@export var picture_material : Material
@export var stair_asset : Node3D

func _ready() -> void:
	for node in stair_asset.get_children():
		if node is MeshInstance3D:
			node.set_surface_override_material(1, picture_material)

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	for node in stair_asset.get_children():
		if node is MeshInstance3D:
			node.set_surface_override_material(1, picture_material)
