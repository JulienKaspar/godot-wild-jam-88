# game_state_manager (autoload)
extends Node

signal on_paused()
signal on_unpaused()
@warning_ignore("unused_signal")
signal show_credits()
signal show_wasted_screen()
@warning_ignore("unused_signal")
signal hide_wasted_screen()

@export var starting_level_index: int = 0
@export var levels: Array[PackedScene]
@export var shader_cashing_level: PackedScene

enum GameState {MainMenu, Game, Paused}
var current_state: GameState = GameState.MainMenu

var post_processing: ColorRect
var player_drunkness: PlayerDrunkness = PlayerDrunkness.new()

var game_camera: GameCamera
var current_player: Player
var loading_into_level_index: int # need this to be set before level starts loading
var loading_screen: LoadingScreen
var precacheCam: Camera3D
var inCacheMode = false
var shader_cache_before_start = true # turn this one on for release

func _ready() -> void:
	get_tree().paused = true
	
func _process(delta: float) -> void:
	player_drunkness.current_drunkness -= player_drunkness.drunkness_decay_per_second * delta


func start_game() -> void:
	get_tree().paused = false
	loading_screen.display(0.2, "Preparing Shader Caching")
	await loading_screen.on_completed
	await cache_shaders()
	LevelLoader.load_level_by_index(starting_level_index,false)
	current_state = GameState.Game
	PlayerMovementUtils.knock_player_down.call_deferred()
	await GameStateManager.current_player.ChangeMovement
	get_tree().paused = true
	loading_screen.display_indefinite(true)
	loading_screen.label.text = "Press enter / start to continue..."
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.break_anticipation)
	await loading_screen.on_ready_to_proceed
	AudioManager.player_sounds.play_voice(AudioManager.player_sounds.break_fence)
	get_tree().paused = false
	AudioManager.ui_sounds.game_started = true
	current_state = GameState.Game
	
func cache_shaders() -> void:
	if !shader_cache_before_start: return
	loading_screen.display_indefinite(false)
	loading_screen.label.text = "Caching Shaders..."
	inCacheMode = true
	var index = 0
	for level in levels:
		LevelLoader.load_level(levels[index])
		if precacheCam:
			print("level has shaders to load:" + levels[index].get_path())
			precacheCam.startCache()
			await precacheCam.completed
		index += 1
	inCacheMode = false

func set_follow_camera(player: Player) -> void:
	game_camera.follow_target = player.get_node("PlayerController/RigidBally3D")

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
	LevelLoader.reload_current_level()
