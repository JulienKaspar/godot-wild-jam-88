## music_manager.gd
extends Node
class_name MusicManager
# =================
# start_music()
# stop_music()
# switch_music(theme : MusicManager.MUSIC_THEMES) - check enum for possible themes
# drunkness_intensity : float - range 0.0 to 1.0
# _update_drunkness_effect() - called when "drunkness_intensity" is updated

@onready var music_player : AudioStreamPlayer = %MusicPlayer
const VOLUME_DB_DEFAULT : float = -3.0
const VOLUME_DB_DUCKING : float = -6.0

var chord_change_timer : Timer

func _ready():
	if !AudioManager.music_manager:
		AudioManager.music_manager = self
	
	GameStateManager.on_paused.connect(_set_filter.bind(true))
	GameStateManager.on_unpaused.connect(_set_filter.bind(false))
	GameStateManager.player_drunkness.on_drunkness_changed.connect(_update_drunk_streams)
	GameStateManager.on_level_loaded.connect(_on_level_change)
	
	setup_chord_changes()

func setup_chord_changes() -> void:
	chord_change_timer = Timer.new()
	chord_change_timer.wait_time = 10.0
	chord_change_timer.one_shot = false
	chord_change_timer.timeout.connect(randomize_chords)
	add_child(chord_change_timer)

func randomize_chords() -> void:
	if !music_player.playing: return
	if randf() < 0.5: return
	
	var _target_theme : int = randi_range(0, MUSIC_THEMES.size() - 1)
	
	if (_target_theme == current_theme): return
	else: switch_music_to_theme(_target_theme)


func _on_level_change(level_index : int) -> void:
	match level_index:
		0: # backyard
			music_player.volume_db = AudioManager.VOLUME_DB_OFF
			if music_player.playing: music_player.stop()
			
		1: # enter house
			if !music_player.playing:
				start_music()
				chord_change_timer.start()
		
		2, 3, 4, 5: # house
			var target_volume_db = VOLUME_DB_DEFAULT
			AudioManager.tween_volume_db(music_player, target_volume_db)
			
		6: # fridge
			chord_change_timer.stop()
			stop_music()


# Music themes - enum makes it easily callable from other scripts
enum MUSIC_THEMES {
	THEME_A,
	THEME_B,
	THEME_C,
	THEME_D,
}

# Currently active theme
var current_theme : MUSIC_THEMES = MUSIC_THEMES.THEME_A

# Bank storing music theme references for transition calls
const MUSIC_BANK : Dictionary[MUSIC_THEMES, String] = {
	MUSIC_THEMES.THEME_A : "theme_a",
	MUSIC_THEMES.THEME_B : "theme_b",
	MUSIC_THEMES.THEME_C : "theme_c",
	MUSIC_THEMES.THEME_D : "theme_d",
}

func start_music() -> void:
	if !music_player.playing: music_player.play()
	AudioManager.fade_audio_in(music_player)

func stop_music() -> void:
	music_player.stop()

func duck_volume() -> void:
	AudioManager.tween_volume_db(music_player, (VOLUME_DB_DEFAULT - 4.5), 1.5)

func restore_volume() -> void:
	AudioManager.tween_volume_db(music_player, VOLUME_DB_DEFAULT, 2.5)

func switch_music_to_theme(theme : MUSIC_THEMES) -> void:
	var _playback : AudioStreamPlaybackInteractive = music_player.get_stream_playback()
	_playback.switch_to_clip_by_name(MUSIC_BANK[theme])
	current_theme = theme
	AudioManager.update_drunk_effects()


# Stream layers of music for each layer of drunkness_intensity
enum DRUNKNESS_STREAMS {
	DEFAULT = 0,
	LOW = 1,
	MED = 2,
	HIGH = 3,
}
# Drunkness cutoff value for music effect triggers
const DRUNK_THRESHOLD_LOW : float = 0.1
const DRUNK_THRESHOLD_MED : float = 0.3
const DRUNK_THRESHOLD_HIGH : float = 0.7

# All drunkness audio processing
func _update_drunk_streams(drunk_value) -> void:
	if !music_player.playing: return
	
	drunk_value = AudioManager.remap_drunkness(drunk_value)
	
	## TODO: CLAMP ALL REMAPS!
	if drunk_value >= DRUNK_THRESHOLD_LOW:
		var _volume : float = remap(drunk_value, DRUNK_THRESHOLD_LOW, 1.0, 0.0, 1.0)
		_volume = clampf(_volume, 0.0, 1.0)
		_volume = linear_to_db(_volume)
		_get_current_theme_stream().set_sync_stream_volume(DRUNKNESS_STREAMS.LOW, _volume)
		
	if drunk_value >= DRUNK_THRESHOLD_MED:
		var _volume : float = remap(drunk_value, DRUNK_THRESHOLD_MED, 1.0, 0.0, 1.0)
		_volume = clampf(_volume, 0.0, 1.0)
		_volume = linear_to_db(_volume)
		_get_current_theme_stream().set_sync_stream_volume(DRUNKNESS_STREAMS.MED, _volume)
			
	if drunk_value >= DRUNK_THRESHOLD_HIGH:
		var _volume : float = remap(drunk_value, DRUNK_THRESHOLD_HIGH, 1.0, 0.0, 1.0)
		_volume = clampf(_volume, 0.0, 1.0)
		_volume = linear_to_db(_volume)
		_get_current_theme_stream().set_sync_stream_volume(DRUNKNESS_STREAMS.HIGH, _volume)

func _get_current_theme_stream() -> AudioStreamSynchronized:
	var _music_playback : AudioStreamPlaybackInteractive = music_player.get_stream_playback()
	var _clip_index : int = _music_playback.get_current_clip_index()
	var _interactive_stream : AudioStreamInteractive = music_player.stream
	
	return _interactive_stream.get_clip_stream(_clip_index) as AudioStreamSynchronized

func _update_drunkness_streams(_target_volume_db) -> void:
	var _interactive_stream : AudioStreamInteractive = music_player.stream
	# iterate clips
	for i in range(0, _interactive_stream.clip_count - 1):
		var _clip = _interactive_stream.get_clip_stream(i) as AudioStreamSynchronized
		# iterate sync streams
		for j in range(0, _clip.stream_count - 1):
			_clip.set_sync_stream_volume(j, _target_volume_db)

const _FILTER_CUTOFF_HZ_ON = 500
const _FILTER_CUTOFF_HZ_OFF = 10000
const _FILTER_FX = 0

var filter_effect : AudioEffectLowPassFilter = AudioServer.get_bus_effect(AudioManager.BUS.MUSIC, 0)

func _set_filter(_enabled : bool, _target_hz : float = -1.0) -> void:
	# target value
	var target_hz : float = _target_hz
	if _target_hz < 0:
		target_hz = _FILTER_CUTOFF_HZ_ON if _enabled else _FILTER_CUTOFF_HZ_OFF
	
	# start value
	filter_effect.cutoff_hz = _FILTER_CUTOFF_HZ_OFF if _enabled else _FILTER_CUTOFF_HZ_ON
	
	# enable if setting on
	if _enabled: AudioServer.set_bus_effect_enabled(AudioManager.BUS.MUSIC, _FILTER_FX, _enabled) # enable effect
	
	# tween
	var t : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(filter_effect, "cutoff_hz", target_hz, 0.25)
	
	# disable if setting off
	if !_enabled:
		# wait for tween to finish
		await t.finished
		AudioServer.set_bus_effect_enabled(AudioManager.BUS.MUSIC, _FILTER_FX, _enabled)
