extends Node3D
class_name PlayerSpawner
const PLAYER = preload("res://Characters/Player/player.tscn")

func _ready() -> void:
	GameStateManager.player_spawner = self

func respawn(new_position: Vector3) -> Player:
	self.position = new_position
	for player in get_children():
		player.free()
	var object = PLAYER.instantiate()
	self.add_child(object)
	
	return object as Player
