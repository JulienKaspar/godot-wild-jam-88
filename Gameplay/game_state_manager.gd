# game_state_manager (autoload)
extends Node

@export var starting_level_index: int = 0
@export var levels: Array[PackedScene]
var post_processing: ColorRect
var player_drunkness: PlayerDrunkness = PlayerDrunkness.new()
var level_loader: LevelLoader
var dialogue_system: DialogueSystem
var game_camera: GameCamera
var player_spawner: PlayerSpawner
var current_player: Player

func _ready() -> void:
	call_deferred(initialize_game.get_method())
	call_deferred(startup_dialogue.get_method())
	Engine.time_scale = 0
	
func _process(delta: float) -> void:
	player_drunkness.current_drunkness -= player_drunkness.drunkness_decay_per_second * delta
	update_drunk_visual_effect()

func update_drunk_visual_effect() -> void:
	var effect_intensity: float = 0.05
	var drunk_effect_intensity = player_drunkness.current_drunkness * effect_intensity * UserSettings.drunk_visual_effect_intensity
	post_processing.material.set('shader_parameter/drunkness', drunk_effect_intensity)

func _unhandled_input(event: InputEvent) -> void:
	var drunkness_per_drink: float = 2
	if event.is_action_pressed("grab_left"):
		player_drunkness.current_drunkness += drunkness_per_drink
		AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.drunkness_up)
	if event.is_action_pressed("grab_right"):
		player_drunkness.current_drunkness += drunkness_per_drink
		AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.drunkness_up)

func register_level_loader(loader: LevelLoader) -> void:
	level_loader = loader

func initialize_game() -> void:
	Engine.time_scale = 1
	load_level_by_index(starting_level_index)

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


func startup_dialogue() -> void:
	dialogue_system.display_dialogue("HOWDY PARTNER LETS GET WASTED")

func show_dialogue(text: String) -> void:
	dialogue_system.display_dialogue(text)
