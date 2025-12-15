extends Node3D

const PLAYER = preload("res://Characters/Player/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var object = PLAYER.instantiate()
	self.add_child(object)

func on_respawn():
	for player in get_children():
		player.free()
	var object = PLAYER.instantiate()
	self.add_child(object)
