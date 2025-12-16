extends Node
class_name MusicManager

signal switch_music(theme : MUSIC_THEMES)

## === DEBUG === ##
@onready var theme_options = $DebugLayer/Control/VBoxContainer/ThemeOptionButton
@onready var drunkness_slider = $DebugLayer/Control/VBoxContainer/DrunknessSlider
@onready var drunkness_label = $DebugLayer/Control/VBoxContainer/DrunknessLabel

@onready var music_player = %MusicPlayer

## TODO: save bus layout structure to ensure consistent effect indexing
var stereo_enhancer_effect : AudioEffectStereoEnhance = AudioServer.get_bus_effect(AudioManager.BUS.MUSIC, AudioManager.FX.STEREO_ENHANCE)
var chorus_effect : AudioEffectChorus = AudioServer.get_bus_effect(AudioManager.BUS.MUSIC, AudioManager.FX.CHORUS)
var phaser_effect : AudioEffectPhaser = AudioServer.get_bus_effect(AudioManager.BUS.MUSIC, AudioManager.FX.PHASER)
var delay_effect : AudioEffectDelay = AudioServer.get_bus_effect(AudioManager.BUS.MUSIC, AudioManager.FX.DELAY)

func _ready():
	_connect_signals()
	_connect_debug_ui()
	#start_music()

func _connect_debug_ui():
	theme_options.item_selected.connect(switch_music_to_theme)
	drunkness_slider.value_changed.connect(_set_drunkness)

func _connect_signals():
	switch_music.connect(switch_music_to_theme)



## === MUSIC === ###
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

func start_music():
	music_player.play()
	update_drunkness_effect()
	
func stop_music():
	music_player.stop()

func switch_music_to_theme(theme : MUSIC_THEMES):
	var _playback : AudioStreamPlaybackInteractive = music_player.get_stream_playback()
	_playback.switch_to_clip_by_name(MUSIC_BANK[theme])
	current_theme = theme
	update_drunkness_effect()



### === DRUNKNESS EFFECT === ##
# Stream layers of music for each layer of drunkness_intensity
enum DRUNKNESS_STREAMS {
	DEFAULT = 0,
	LOW = 1,
	MED = 2,
	HIGH = 3,
}
# Drunkness cutoff value for music effect triggers
const DRUNKNESS_LOW : float = 0.1
const DRUNKNESS_MED : float = 0.35
const DRUNKNESS_HIGH : float = 0.75

## TODO: replace class var with global drunkness value or signal
# Intensity value used for drunkness effect calculations
var drunkness_intensity: float:
	set(value):
		drunkness_intensity = value
		update_drunkness_effect()

# Func for debug slider call
func _set_drunkness(value : float):
	drunkness_intensity = value

# All drunkness audio processing
func update_drunkness_effect():
	if drunkness_intensity < 0.0 or drunkness_intensity > 1.0:
		push_warning("music_manager.gd: update_drunk_music(drunkness_intensity) - drunkness_intensity parameter must be between 0.0 and 1.0")
		return
	
	if drunkness_intensity >= DRUNKNESS_LOW:
		_get_current_theme_stream().set_sync_stream_volume(
			DRUNKNESS_STREAMS.LOW, 
			linear_to_db(remap(drunkness_intensity, DRUNKNESS_LOW, 1.0, 0.0, 1.0)))
		
	if drunkness_intensity >= DRUNKNESS_MED:
		_get_current_theme_stream().set_sync_stream_volume(
			DRUNKNESS_STREAMS.MED, 
			linear_to_db(remap(drunkness_intensity, DRUNKNESS_MED, 1.0, 0.0, 1.0)))
			
	if drunkness_intensity >= DRUNKNESS_HIGH:
		_get_current_theme_stream().set_sync_stream_volume(
			DRUNKNESS_STREAMS.HIGH, 
			linear_to_db(remap(drunkness_intensity, DRUNKNESS_HIGH, 1.0, 0.0, 1.0)))
		
		# Delay effect
		delay_effect.dry = 1.0 - drunkness_intensity * 0.25
		delay_effect.tap1_level_db = linear_to_db(remap(drunkness_intensity, DRUNKNESS_HIGH, 1.0, 0.0, 0.25))
		delay_effect.tap2_level_db = linear_to_db(remap(drunkness_intensity, DRUNKNESS_HIGH, 1.0, 0.0, 0.25))
		delay_effect.feedback_level_db = linear_to_db(remap(drunkness_intensity, DRUNKNESS_HIGH, 1.0, 0.0, 0.25))
		
		# Phaser effect
		phaser_effect.feedback = remap(drunkness_intensity, DRUNKNESS_HIGH, 1.0, 0.1, 0.4)
		phaser_effect.rate_hz = remap(drunkness_intensity, DRUNKNESS_HIGH, 1.0, 0.01, 5.0)
		phaser_effect.depth = remap(drunkness_intensity, DRUNKNESS_HIGH, 1.0, 0.1, 0.3)
	
	# Stereo enhance
	stereo_enhancer_effect.pan_pullout = remap(drunkness_intensity, DRUNKNESS_LOW, 1.0, 1.0, 4.0)
	
	# Chorus
	chorus_effect.dry = 1.0 - drunkness_intensity * 0.5
	chorus_effect.wet = remap(drunkness_intensity, DRUNKNESS_MED, 1.0, 0.0, 0.7)
	
	# Debug
	drunkness_label.text = str("Drunkness: ", drunkness_intensity)

func _get_current_theme_stream() -> AudioStreamSynchronized:
	var _music_playback : AudioStreamPlaybackInteractive = music_player.get_stream_playback()
	var _clip_index : int = _music_playback.get_current_clip_index()
	var _interactive_stream : AudioStreamInteractive = music_player.stream
	
	return _interactive_stream.get_clip_stream(_clip_index) as AudioStreamSynchronized
