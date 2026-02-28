@tool
extends Node3D
@onready var achievement_info: Node3D = %AchievementInfo
@onready var achievement_name: Label = $AchievementInfo/Sprite3D/SubViewport/VBoxContainer/AchievementName
@onready var achievement_description: Label = $AchievementInfo/Sprite3D/SubViewport/VBoxContainer/AchievementDescription

@export var achievement: Achievement
@export var picture_material: Material
@export_category("Swappable Models")
@export var models: Array[PackedScene] = []
@export var model_index: int = 0: 
	set(value):
		change_model(value)
		change_material()
		model_index = value
@export var model_slot: Node3D

func _ready() -> void:
	if achievement != null:
		@warning_ignore("standalone_ternary")
		change_model(model_index) if achievement.obtained else change_model(5)
		initialize_achievement_info()
	change_material()
	

func change_material() -> void:
	for child in model_slot.get_children():
		var material: Material = picture_material if achievement == null else achievement.material
		print(child)
		if child is MeshInstance3D:
			child.set_surface_override_material(1, material)
		elif child.get_child(0) is MeshInstance3D:
			child.get_child(0).set_surface_override_material(1, material)

func change_model(index: int) -> void:
	for child in model_slot.get_children():
		child.queue_free()
	
	var instance = models[index % models.size()].instantiate()
	model_slot.add_child(instance)

func initialize_achievement_info() -> void:
	achievement_name.text = achievement.name
	achievement_description.text = achievement.description
	achievement_info.show()
	
