# game_state_manager (autoload)
extends Node

signal on_paused()
signal on_unpaused()
signal on_level_loaded(level_index : int)

@export var starting_level_index: int = 0
@export var levels: Array[PackedScene]
@export var shader_cashing_level: PackedScene

enum GameState {Main_Menu, Paused, Game, Transition}
var current_state: GameState = GameState.Main_Menu

var post_processing: ColorRect
var player_drunkness: PlayerDrunkness = PlayerDrunkness.new()
var level_loader: LevelLoader
var dialogue_system: DialogueSystem
var game_camera: GameCamera
var player_spawner: PlayerSpawner
var current_player: Player
var current_level_index: int
var loading_screen: LoadingScreen

func _ready() -> void:
	get_tree().paused = true
	player_drunkness.on_sobriety.connect(handle_sobriety.call_deferred)
	
func _process(delta: float) -> void:
	player_drunkness.current_drunkness -= player_drunkness.drunkness_decay_per_second * delta
	update_drunk_visual_effect()

func update_drunk_visual_effect() -> void:
	var effect_intensity: float = 0.05
	var drunk_effect_intensity = player_drunkness.current_drunkness * effect_intensity * clampf(UserSettings.drunk_visual_effect_intensity, 0.1, 1)
	post_processing.material.set('shader_parameter/drunkness', drunk_effect_intensity)

func register_level_loader(loader: LevelLoader) -> void:
	level_loader = loader

func start_game() -> void:
	get_tree().paused = false
	await cache_shaders()
	load_level_by_index(starting_level_index,false)
	current_state = GameState.Game
	PlayerMovementUtils.knock_player_down.call_deferred()
	loading_screen.display(3 * UserSettings.loading_speed)
	AudioManager.ui_sounds.volume_db = AudioManager._VOLUME_DB_OFF
	await loading_screen.on_completed
	AudioManager.ui_sounds.game_started
	
	
func cache_shaders() -> void:
	loading_screen.display_indefinite()
	loading_screen.label.text = "Caching Shaders..."
	var instance: ShaderCashing = level_loader.load_level(shader_cashing_level)
	await instance.completed
	loading_screen.close()

func find_spawn_point_in_level(level: Node3D) -> Vector3:
	for child in level.get_children():
		if child is PlayerSpawnPoint:
			return child.position
	return Vector3(0,0,0)

func set_follow_camera(player: Player) -> void:
	game_camera.follow_target = player.get_node("PlayerController/RigidBally3D")

func load_level_by_index(index: int, show_loading_screen: bool) -> void:
	if show_loading_screen:
		loading_screen.display(2 * UserSettings.loading_speed)
		pause_game()
	var loaded_level = level_loader.load_level(levels[index])
	var spawn_point = find_spawn_point_in_level(loaded_level)
	var player = player_spawner.respawn(spawn_point)
	if current_player != null:
		current_player.queue_free()
	current_player = player
	call_deferred(set_follow_camera.get_method(),player)
	current_level_index = index
	
	if show_loading_screen:
		await loading_screen.on_completed
		unpause_game()
		
	on_level_loaded.emit(index)

func next_level() -> void:
	if current_level_index == levels.size() - 1:
		print("you finished the game!")
		return
	
	load_level_by_index(current_level_index + 1, true)

func show_dialogue(text: String) -> void:
	dialogue_system.display_dialogue(text)

func toggle_pause() -> void:
	match current_state:
		GameState.Paused:
			unpause_game()
		GameState.Game:
			pause_game()

func pause_game() -> void:
	if current_state == GameState.Game:
		get_tree().paused = true
		current_state = GameState.Paused
		on_paused.emit()
	
func unpause_game() -> void:
	if current_state == GameState.Paused:
		get_tree().paused = false
		current_state = GameState.Game
		on_unpaused.emit()
		
func handle_sobriety() -> void:
	if UserSettings.fail_state:
		dialogue_system.display_dialogue("We got a little too sober, lets try again")
		reset_level()

func reset_level() -> void:
	load_level_by_index(current_level_index, false)
	player_drunkness.reset_drunkness()
