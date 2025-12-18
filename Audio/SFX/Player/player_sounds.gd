# player_sounds.gd #
extends Node3D
class_name PlayerSounds

@export var footstep_player : AudioStreamPlayer3D
@export var voice_player : AudioStreamPlayer3D
@export var singing_player : AudioStreamPlayer3D


@export var falling_sounds : AudioStreamRandomizer
@export var getting_up_sounds : AudioStreamRandomizer
@export var hurt_sounds : AudioStreamRandomizer
@export var burp_sounds : AudioStreamRandomizer

@export_range(0.0, 1.0) var burp_nastiness : float = 0.5:  # range (0.0, 1.0)
	set(value):
		select_burps(value)

var ducking_singing : bool = false

func _ready():
	# setup singleton
	if AudioManager.player_sounds == null:
		AudioManager.player_sounds = self
	
	select_burps(burp_nastiness)

func play_voice(voice_stream : AudioStream):
	if voice_player.playing: 
		print("PlayerSounds: voice_player is already playing a sound")
		return
	
	if singing_player.playing: duck_singing_volume()
	
	voice_player.stream = voice_stream
	voice_player.play()

func duck_singing_volume():
	AudioManager.fade_audio_out(singing_player, 0.15)
	if !voice_player.finished.has_connections():
		voice_player.finished.connect(restore_singing_volume)

func restore_singing_volume():
	await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
	if !voice_player.playing:
		AudioManager.fade_audio_in(singing_player, 0.0, 0.5)
	else:
		restore_singing_volume() # recursion yay!


func select_burps(intensity : float):
	var sum : float = burp_sounds.streams_count
	var mean : float = sum * intensity
	var center : int = round(mean)
	var max_dist : int = 5
	for i in range(sum - 1):
		var diff = abs(i - center)
		var prob : float = remap(diff, 0, max_dist, 1.0, 0.5) if (diff <= max_dist) else 0.0
		burp_sounds.set_stream_probability_weight(i, prob)
	
