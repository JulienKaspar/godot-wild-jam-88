# game_state_manager (autoload)
extends Node

signal on_paused()
signal on_unpaused()
@warning_ignore("unused_signal")
signal show_credits()
signal show_wasted_screen()
@warning_ignore("unused_signal")
signal hide_wasted_screen()
signal on_level_loaded(level_index : int)

@export var starting_level_index: int = 0
@export var levels: Array[PackedScene]
@export var shader_cashing_level: PackedScene

enum GameState {Main_Menu, Paused, Game, Loading_Screen, Settings}
var current_state: GameState = GameState.Main_Menu

var post_processing: ColorRect
var player_drunkness: PlayerDrunkness = PlayerDrunkness.new()
var level_loader: LevelLoader
var dialogue_system: DialogueSystem
var game_camera: GameCamera
var player_spawner: PlayerSpawner
var current_player: Player
var current_level_index: int
var loading_into_level_index: int # need this to be set before level starts loading
var loading_screen: LoadingScreen
var precacheCam: Camera3D
var inCacheMode = false
var shader_cache_before_start = true # turn this one on for release

func _ready() -> void:
	get_tree().paused = true
	
func _process(delta: float) -> void:
	player_drunkness.current_drunkness -= player_drunkness.drunkness_decay_per_second * delta

func register_level_loader(loader: LevelLoader) -> void:
	level_loader = loader

func start_game() -> void:
	get_tree().paused = false
	await cache_shaders()
	loading_screen.display_indefinite(true)
	loading_screen.label.text = "Setting things up..."

	load_level_by_index(starting_level_index,false)
	current_state = GameState.Game
	PlayerMovementUtils.knock_player_down.call_deferred()
	await GameStateManager.current_player.ChangeMovement
	get_tree().paused = true
	loading_screen.label.text = "Press enter / start to continue..."
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.break_anticipation)
	await loading_screen.on_ready_to_proceed
	AudioManager.player_sounds.play_voice(AudioManager.player_sounds.break_fence)
	get_tree().paused = false
	AudioManager.ui_sounds.game_started = true
	
func cache_shaders() -> void:
	if !shader_cache_before_start: return
	loading_screen.display_indefinite(false)
	loading_screen.label.text = "Caching Shaders..."
	inCacheMode = true
	var index = 0
	for level in levels:
		level_loader.load_level(levels[index])
		if precacheCam:
			print("level has shaders to load:" + levels[index].get_path())
			precacheCam.startCache()
			await precacheCam.completed
		index += 1
	inCacheMode = false
	loading_screen.close()

func find_spawn_point_in_level(level: Node3D) -> Vector3:
	for child in level.get_children():
		if child is PlayerSpawnPoint:
			return child.position
	return Vector3(0,0,0)

func set_follow_camera(player: Player) -> void:
	game_camera.follow_target = player.get_node("PlayerController/RigidBally3D")

func load_level_by_index(index: int, show_loading_screen: bool) -> void:
	loading_into_level_index = index
	
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
		


func reset_level() -> void:
	player_drunkness.paused = false
	player_drunkness.reset_drunkness()
	load_level_by_index(current_level_index, false)
