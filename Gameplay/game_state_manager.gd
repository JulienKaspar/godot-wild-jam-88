# game_state_manager (autoload)
extends Node

@warning_ignore("unused_signal")
signal move_player_and_reset(position: Vector3)

@export var levels: Array[PackedScene]
var player_drunkness: PlayerDrunkness = PlayerDrunkness.new()
var level_loader: LevelLoader
var dialogue_system: DialogueSystem
var game_camera: GameCamera
var player_spawner: PlayerSpawner

func _ready() -> void:
	call_deferred(initialize_game.get_method())
	call_deferred(startup_dialogue.get_method())
	Engine.time_scale = 0
	
func _process(delta: float) -> void:
	player_drunkness.current_drunkness -= player_drunkness.drunkness_decay_per_second * delta


func register_level_loader(loader: LevelLoader) -> void:
	level_loader = loader

func initialize_game() -> void:
	level_loader.load_level(levels[0])
	Engine.time_scale = 1
	var player = player_spawner.respawn(Vector3(0,0,0))
	call_deferred(set_follow_camera.get_method(),player)

func set_follow_camera(player: Player) -> void:
	game_camera.follow_target = player.get_node("PlayerController/RigidBally3D")

func load_level_by_index(index: int) -> void:
	level_loader.load_level(levels[index])

func startup_dialogue() -> void:
	dialogue_system.display_dialogue("HOWDY PARTNER LETS GET WASTED")

func show_dialogue(text: String) -> void:
	dialogue_system.display_dialogue(text)
