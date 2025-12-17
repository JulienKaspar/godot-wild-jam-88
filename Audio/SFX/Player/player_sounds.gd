# player_sounds.gd #
extends Node3D
class_name PlayerSounds

@export var footstep_player : AudioStreamPlayer3D
@export var voice_player : AudioStreamPlayer3D
@export var singing_player : AudioStreamPlayer3D

@export var falling_sounds : AudioStream
@export var getting_up_sounds : AudioStream
@export var hurt_sounds : AudioStream

func _ready():
	# setup singleton
	if AudioManager.player_sounds == null:
		AudioManager.player_sounds = self

func play_voice(voice_stream : AudioStream):
	if voice_player.playing: 
		print("PlayerSounds: voice_player is already playing a sound")
		return
	voice_player.stream = voice_stream
	voice_player.play()
