@tool
extends Node3D

@export var picture_material : Material

@export_category("Swappable Models")
@export var models: Array[PackedScene] = []
@export var model_index: int = 0: 
	set(value):
		change_model(value)
		change_material()
		model_index = value
@export var model_slot: Node3D

func _ready() -> void:
	change_model(model_index)
	change_material()

func change_material() -> void:
	for child in model_slot.get_children():
		print(child)
		if child is MeshInstance3D:
			child.set_surface_override_material(1, picture_material)
		elif child.get_child(0) is MeshInstance3D:
			child.get_child(0).set_surface_override_material(1, picture_material)

func change_model(index: int) -> void:
	for child in model_slot.get_children():
		child.queue_free()
	
	var instance = models[index % models.size()].instantiate()
	model_slot.add_child(instance)
