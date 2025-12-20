# player_sounds.gd #
extends Node3D
class_name PlayerSounds

@export var footstep_player : AudioStreamPlayer3D
@export var voice_player : AudioStreamPlayer3D
@export var singing_player : AudioStreamPlayer3D

@export var falling_sounds : AudioStreamRandomizer
@export var getting_up_sounds : AudioStreamRandomizer
@export var hurt_sounds : AudioStreamRandomizer
@export var chug_sounds : AudioStreamRandomizer
@export var burp_sounds : AudioStreamRandomizer
@export var hiccup_sounds : AudioStreamRandomizer

var hiccup_timer : Timer
var burp_timer : Timer
var drinking_timer : Timer
var is_drinking : bool = false

@export_range(0.0, 1.0) var burp_nastiness : float = UserSettings.burp_nastiness:  # range (0.0, 1.0)
	set(value):
		select_burps(value)

var ducking_singing : bool = false

func _ready():
	# setup singleton
	if AudioManager.player_sounds == null:
		AudioManager.player_sounds = self
	
	select_burps(burp_nastiness)
	setup_burps()
	setup_hiccups()
	setup_drinking()

func play_voice(voice_stream : AudioStream) -> void:
	if voice_player.playing: 
		print("PlayerSounds: voice_player is already playing a sound")
		return
	
	if singing_player.playing:
		if voice_stream == chug_sounds:
			set_singing_filter(true)
		else:
			duck_singing_volume()
	
	match voice_stream:
		chug_sounds:
			if is_drinking: 
				return
			else:
				is_drinking = true
				drinking_timer.start()
	
	voice_player.stream = voice_stream
	voice_player.play()

func duck_singing_volume() -> void:
	AudioManager.fade_audio_out(singing_player, 0.15)
	if !voice_player.finished.has_connections():
		voice_player.finished.connect(restore_singing_volume)

func restore_singing_volume() -> void:
	await get_tree().create_timer(randf_range(0.35, 0.8)).timeout
	if !voice_player.playing:
		AudioManager.fade_audio_in(singing_player, 0.0, 0.35)
	else:
		restore_singing_volume() # recursion yay!


func select_burps(intensity : float) -> void:
	var sum : float = burp_sounds.streams_count
	var mean : float = sum * intensity
	var center : int = round(mean)
	var max_dist : int = 5
	for i in range(sum - 1):
		var diff : int = abs(i - center)
		var prob : float = remap(diff, 0, max_dist, 1.0, 0.5) if (diff <= max_dist) else 0.0
		burp_sounds.set_stream_probability_weight(i, prob)

func setup_burps() -> void:
	burp_timer = Timer.new()
	burp_timer.one_shot = true
	burp_timer.wait_time = randf_range(0.5, 1.2)
	burp_timer.timeout.connect(
		func():
			play_voice(burp_sounds)
			burp_timer.wait_time = randf_range(0.5, 1.2)
	)
	add_child(burp_timer)

func setup_drinking() -> void:
	drinking_timer = Timer.new()
	drinking_timer.one_shot = true
	drinking_timer.wait_time = 0.5
	drinking_timer.timeout.connect(
		func(): 
			is_drinking = false
			get_tree().create_timer(.8).timeout.connect(set_singing_filter.bind(false))
			burp_timer.start()
	)
	add_child(drinking_timer)


func setup_hiccups() -> void:
	hiccup_timer = Timer.new()
	hiccup_timer.one_shot = false
	hiccup_timer.timeout.connect(
		func(): 
			hiccup_timer.wait_time = randf_range(1.5, 2.5) # randomize hiccup timing
			if randf() > 0.5:
				play_voice(hiccup_sounds) # play random hiccup sound
			# stop after some time
			get_tree().create_timer(randf_range(4.0, 6.0)).timeout.connect(hiccup_timer.stop) 
	)
	GameStateManager.player_drunkness.on_too_drunk.connect(hiccup_timer.start)
	add_child(hiccup_timer)
	

const _FILTER_CUTOFF_HZ_ON = 200
const _FILTER_CUTOFF_HZ_OFF = 10000
const _FILTER_FX = 0

var filter_effect : AudioEffectLowPassFilter = AudioServer.get_bus_effect(AudioManager.BUS.PLAYER, _FILTER_FX)

func set_singing_filter(_enabled : bool, _target_hz : float = -1.0):
	# target value
	var target_hz : float = _target_hz
	if _target_hz < 0:
		target_hz = _FILTER_CUTOFF_HZ_ON if _enabled else _FILTER_CUTOFF_HZ_OFF
	
	# start value
	filter_effect.cutoff_hz = _FILTER_CUTOFF_HZ_OFF if _enabled else _FILTER_CUTOFF_HZ_ON
	
	# enable if setting on
	if _enabled: AudioServer.set_bus_effect_enabled(AudioManager.BUS.PLAYER, _FILTER_FX, _enabled) # enable effect
	
	# tween
	var t : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#var tween_speed : float = 0.15 if _enabled else 0.35
	t.tween_property(filter_effect, "cutoff_hz", target_hz, 0.5)
	
	# disable if setting off
	if !_enabled:
		# wait for tween to finish
		await t.finished
		AudioServer.set_bus_effect_enabled(AudioManager.BUS.PLAYER, _FILTER_FX, _enabled)
