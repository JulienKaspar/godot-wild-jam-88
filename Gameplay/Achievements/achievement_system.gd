#AchievementSystem (autoload)
extends Node

var obtainable_achievements: Array[Achievement]
@export var achievements_resource_group: ResourceGroup

func _ready() -> void:
	achievements_resource_group.load_all_into(obtainable_achievements)
