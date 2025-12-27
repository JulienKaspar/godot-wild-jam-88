extends Node3D
class_name PlayerSpawner
const PLAYER = preload("res://Characters/Player/player.tscn")

func _ready() -> void:
	GameStateManager.level_loader.player_spawner = self

func respawn(new_position: Vector3) -> Player:
	self.position = new_position
	for player in get_children():
		player.free()
	var object = PLAYER.instantiate()
	self.add_child(object)
	
	return object as Player

func spawn_another(new_position : Vector3) -> Player:
	for player in get_children():
		remove_child(player)
		
	self.position = new_position
	var player_object = PLAYER.instantiate()
	self.add_child(player_object)
	return player_object as Player
