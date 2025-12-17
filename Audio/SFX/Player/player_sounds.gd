# player_sounds.gd #
extends Node3D
class_name PlayerSounds

@export var footstep_player : AudioStreamPlayer3D
@export var voice_player : AudioStreamPlayer3D
@export var singing_player : AudioStreamPlayer3D

var ducking_singing : bool = false

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
	
	if singing_player.playing: duck_singing_volume()
	
	voice_player.stream = voice_stream
	voice_player.play()

func duck_singing_volume():
	AudioManager.fade_audio_out(singing_player, 0.15)
	voice_player.finished.connect(restore_singing_volume)

func restore_singing_volume():
	await get_tree().create_timer(randf_range(1.0, 2.5)).timeout
	if !voice_player.playing:
		AudioManager.fade_audio_in(singing_player, 0.0, 0.5)
	else:
		restore_singing_volume() # recursion yay!
