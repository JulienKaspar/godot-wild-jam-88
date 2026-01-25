#AchievementSystem (autoload)
extends Node

var obtainable_achievements: Array[Achievement]
@export var achievements_resource_group: ResourceGroup

func _ready() -> void:
	achievements_resource_group.load_all_into(obtainable_achievements)

func unlock_achievement(id: Achievement.ID) -> void:
	for achievement in obtainable_achievements:
		if achievement.id != id: continue
		if achievement.obtained == true: return
		
		achievement.unlock()
		display_effects(achievement)

func is_achievement_already_unlocked(id: Achievement.ID) -> bool:
	for achievement in obtainable_achievements:
		if achievement.id == id:
			return achievement.obtained
	return false

@warning_ignore("unused_parameter")
func display_effects(achievement: Achievement) -> void:
	print(achievement.name + " GOT!!!!")
