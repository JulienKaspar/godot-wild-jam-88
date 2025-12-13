extends Node
class_name MusicManager

@onready var music_player = %MusicPlayer

signal switch_music(theme : MUSIC_THEMES)

enum MUSIC_THEMES {
	THEME_A,
	THEME_B,
	THEME_C,
	THEME_D,
}

const MUSIC_BANK : Dictionary[MUSIC_THEMES, String] = {
	MUSIC_THEMES.THEME_A : "theme_a",
	MUSIC_THEMES.THEME_B : "theme_b",
	MUSIC_THEMES.THEME_C : "theme_c",
	MUSIC_THEMES.THEME_D : "theme_d",
}

enum DRUNKNESS_LAYERS {
	DEFAULT = 0,
	LOW = 1,
	HIGH = 2
}


func _ready():
	_connect_signals()
	_connect_debug_ui()
	_setup_effect_handlers()
	start_music()

## === MUSIC === ###
func start_music():
	music_player.play()
	update_drunkness_effect(0.0)

func stop_music():
	music_player.stop()

func switch_music_to_theme(theme : MUSIC_THEMES):
	music_player.set("parameters/switch_to_clip", MUSIC_BANK[theme])
	update_drunkness_effect(drunkness_slider.value)



### === DRUNKNESS EFFECT === ##
## TODO: Move BUS information to global AudioManager class to expose bus volume settings
const BUS : Dictionary[String, int] = {
	"MASTER" : 0,
	"MUSIC" : 1,
}

## TODO: save bus layout structure to ensure consistent effect indexing
var stereo_enhancer_effect : AudioEffectStereoEnhance
var chorus_effect : AudioEffectChorus
var phaser_effect : AudioEffectPhaser
var delay_effect : AudioEffectDelay

func _setup_effect_handlers():
	stereo_enhancer_effect = AudioServer.get_bus_effect(BUS["MUSIC"], 0)
	chorus_effect = AudioServer.get_bus_effect(BUS["MUSIC"], 1)
	phaser_effect = AudioServer.get_bus_effect(BUS["MUSIC"], 2)
	delay_effect = AudioServer.get_bus_effect(BUS["MUSIC"], 3)

func update_drunkness_effect(amount : float = -1.0):
	if amount < 0.0 or amount > 1.0:
		push_warning("music_manager.gd: update_drunk_music(amount) - amount parameter must be between 0.0 and 1.0")
		return
	
	if amount > 0.0:
		_get_current_theme_stream().set_sync_stream_volume(DRUNKNESS_LAYERS.LOW, linear_to_db(remap(amount, 0.0, 0.5, 0.0, 1.0)))
	if amount > 0.5:
		_get_current_theme_stream().set_sync_stream_volume(DRUNKNESS_LAYERS.HIGH, linear_to_db(remap(amount, 0.5, 1.0, 0.0, 1.0)))
	
	if !is_instance_valid(stereo_enhancer_effect):
		push_warning("AudioBus.Music:StereoEnhance effect could not be located")
	else:
		stereo_enhancer_effect.pan_pullout = remap(amount, 0.0, 1.0, 1.0, 4.0)
		
	if !is_instance_valid(chorus_effect):
		push_warning("AudioBus.Music:Chorus effect could not be located")
	else:
		chorus_effect.dry = 1.0 - amount
		chorus_effect.wet = remap(amount, 0.0, 1.0, 0.0, 0.7)
		
	if !is_instance_valid(phaser_effect):
		push_warning("AudioBus.Music:Phaser effect could not be located")
	else:
		phaser_effect.feedback = remap(amount, 0.5, 1.0, 0.1, 0.4)
		phaser_effect.rate_hz = remap(amount, 0.5, 1.0, 0.01, 5.0)
		phaser_effect.depth = remap(amount, 0.5, 1.0, 0.1, 0.3)
		
	if !is_instance_valid(delay_effect):
		push_warning("AudioBus.Music:Delay effect could not be located")
	else:
		delay_effect.dry = 1.0 - amount * 0.3
		delay_effect.tap1_level_db = linear_to_db(remap(amount, 0.0, 1.0, 0.0, 0.1))
		delay_effect.tap2_level_db = linear_to_db(remap(amount, 0.0, 1.0, 0.0, 0.1))
		delay_effect.feedback_level_db = linear_to_db(remap(amount, 0.0, 1.0, 0.0, 0.1))
	
	drunkness_label.text = str("Drunkness: ", amount)

func _get_current_theme_stream() -> AudioStreamSynchronized:
	var _music_playback : AudioStreamPlaybackInteractive = music_player.get_stream_playback()
	var _clip_index : int = _music_playback.get_current_clip_index()
	var _interactive_stream : AudioStreamInteractive = music_player.stream
	
	return _interactive_stream.get_clip_stream(_clip_index) as AudioStreamSynchronized


func _connect_signals():
	switch_music.connect(switch_music_to_theme)

## === DEBUG === ##
@onready var theme_options = $DebugLayer/Control/VBoxContainer/ThemeOptionButton
@onready var drunkness_slider = $DebugLayer/Control/VBoxContainer/DrunknessSlider
@onready var drunkness_label = $DebugLayer/Control/VBoxContainer/DrunknessLabel

func _connect_debug_ui():
	theme_options.item_selected.connect(switch_music_to_theme)
	drunkness_slider.value_changed.connect(update_drunkness_effect)
