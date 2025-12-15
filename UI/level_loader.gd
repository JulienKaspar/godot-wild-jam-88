extends Node
class_name LevelLoader

func _ready() -> void:
	GameStateManager.register_level_loader(self)

func load_level(scene: PackedScene) -> void:
	for child in get_children():
		child.queue_free()
	
	var level = scene.instantiate()
	add_child(level)
