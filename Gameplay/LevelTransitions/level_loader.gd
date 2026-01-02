extends Node

signal on_level_loaded()

var loading_into_level_index: int
var loading_screen: LoadingScreen # need to get
var levels: Array[PackedScene] # need to get
var player_spawner: PlayerSpawner
var current_level_index: int

func _ready() -> void: 
	levels = GameStateManager.levels

func _process(_delta: float) -> void:
	checkLevelIssues()

func checkLevelIssues() -> void:
	if GameStateManager.current_player:
		if GameStateManager.current_player.player_global_pos.y < -100: GameStateManager.next_level()

func next_level() -> void:
	if current_level_index == levels.size() - 1:
		print("you finished the game!")
		return
	
	load_level_by_index(current_level_index + 1, true)

func load_level(scene: PackedScene) -> Node3D:
	GameStateManager.game_camera.hardFollowPlayer()
	for child in get_children():
		child.queue_free()
	
	var level = scene.instantiate()
	add_child(level)
	return level

func load_level_by_index(index: int, show_loading_screen: bool) -> void:
	loading_into_level_index = index
	
	if show_loading_screen:
		loading_screen.display(2 * UserSettings.loading_speed)
		GameStateManager.pause_game()
		
	var loaded_level = load_level(levels[index])
	var spawn_point = find_spawn_point_in_level(loaded_level)
	var player = player_spawner.respawn(spawn_point)
	var current_player = GameStateManager.current_player
	if current_player != null:
		current_player.queue_free()
	current_player = player
	GameStateManager.current_player = player
	call_deferred(set_follow_camera.get_method(),player)
	
	current_level_index = index
	
	if show_loading_screen:
		await loading_screen.on_completed
		GameStateManager.unpause_game()
		
	on_level_loaded.emit(index)
	
func find_spawn_point_in_level(level: Node3D) -> Vector3:
	for child in level.get_children():
		if child is PlayerSpawnPoint:
			return child.position
	return Vector3(0,0,0)

func load_achievement_level() -> void:
	var loaded_level = load_level(GameStateManager.achievement_scene)
	var spawn_point = find_spawn_point_in_level(loaded_level)
	
	var player = player_spawner.respawn(spawn_point)
	var current_player = GameStateManager.current_player
	if current_player != null:
		current_player.queue_free()
	current_player = player
	GameStateManager.current_player = player
	
	call_deferred(set_follow_camera.get_method(), player)
	get_tree().paused = false
	GameStateManager.player_drunkness.paused = true
	GameStateManager.current_state = GameStateManager.GameState.Game

func set_follow_camera(player: Player) -> void:
	GameStateManager.game_camera.follow_target = player.get_node("PlayerController/RigidBally3D")
