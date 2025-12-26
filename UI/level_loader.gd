extends Node
class_name LevelLoader

func _ready() -> void:
	GameStateManager.register_level_loader(self)

func _process(_delta: float) -> void:
	checkLevelIssues()

func checkLevelIssues() -> void:
	if GameStateManager.current_player:
		if GameStateManager.current_player.player_global_pos.y < -100: GameStateManager.next_level()

func load_level(scene: PackedScene) -> Node3D:
	GameStateManager.game_camera.hardFollowPlayer()
	for child in get_children():
		child.queue_free()
	
	var level = scene.instantiate()
	add_child(level)
	return level
