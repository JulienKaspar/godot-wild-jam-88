# player_sounds.gd #
extends Node3D
class_name PlayerSounds

@export var footstep_player : AudioStreamPlayer3D
@export var voice_player : AudioStreamPlayer3D
@export var singing_player : AudioStreamPlayer3D

func _ready():
	# setup singleton
	if AudioManager.player_sounds == null:
		AudioManager.player_sounds = self
