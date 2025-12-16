# game_state_manager (autoload)
extends Node

@warning_ignore("unused_signal")
signal move_player_and_reset(position: Vector3)

@export var levels: Array[PackedScene]
var level_loader: LevelLoader
var dialogue_system: DialogueSystem
var player: Player

func _ready() -> void:
	call_deferred(initialize_game.get_method())
	call_deferred(startup_dialogue.get_method())
	

func register_level_loader(loader: LevelLoader) -> void:
	level_loader = loader

func initialize_game() -> void:
	level_loader.load_level(levels[0])

func load_level_by_index(index: int) -> void:
	level_loader.load_level(levels[index])

func startup_dialogue() -> void:
	dialogue_system.display_dialogue("HOWDY PARTNER LETS GET WASTED")

func show_dialogue(text: String) -> void:
	dialogue_system.display_dialogue(text)
