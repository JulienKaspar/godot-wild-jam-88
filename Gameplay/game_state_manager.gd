# game_state_manager (autoload)
extends Node

signal on_paused()
signal on_unpaused()

@export var starting_level_index: int = 0
@export var levels: Array[PackedScene]

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

func _ready() -> void:
	get_tree().paused = true
	start_game()
		
func _process(delta: float) -> void:
	player_drunkness.current_drunkness -= player_drunkness.drunkness_decay_per_second * delta
	update_drunk_visual_effect()

func update_drunk_visual_effect() -> void:
	var effect_intensity: float = 0.05
	var drunk_effect_intensity = player_drunkness.current_drunkness * effect_intensity * UserSettings.drunk_visual_effect_intensity
	post_processing.material.set('shader_parameter/drunkness', drunk_effect_intensity)

func register_level_loader(loader: LevelLoader) -> void:
	level_loader = loader

func start_game() -> void:
	get_tree().paused = false
	load_level_by_index(starting_level_index)
	current_state = GameState.Game

func find_spawn_point_in_level(level: Node3D) -> Vector3:
	for child in level.get_children():
		if child is PlayerSpawnPoint:
			return child.position
	return Vector3(0,0,0)

func set_follow_camera(player: Player) -> void:
	game_camera.follow_target = player.get_node("PlayerController/RigidBally3D")

func load_level_by_index(index: int) -> void:
	var loaded_level = level_loader.load_level(levels[index])
	var spawn_point = find_spawn_point_in_level(loaded_level)
	var player = player_spawner.respawn(spawn_point)
	if current_player != null:
		current_player.queue_free()
	current_player = player
	call_deferred(set_follow_camera.get_method(),player)
	current_level_index = index

func next_level() -> void:
	if current_level_index == levels.size() - 1:
		print("you finished the game!")
		return
	
	load_level_by_index(current_level_index + 1)

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
