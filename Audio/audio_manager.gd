# audio_manager.gd (autoload)
extends Node
# ================
# contains singleton global audio classes (music, ui, player, sfx)
# stores default audio values
# handles drunkness processing (update_drunk_effects)
# helper functions (fade_audio_in, fade_audio_out, tween_volume_db)

# global audio classes
var music_manager : MusicManager
var ui_sounds : UI_Sounds
var player_sounds : PlayerSounds
var sfx_manager : SoundEffectsPool

# bus index
enum BUS {
	MASTER,
	DRUNK_FX,
	MUSIC,
	SFX,
	AMBIENCE,
	UI,
	PLAYER,
	FLASKY,
}

# fx index
enum FX {
	STEREO_ENHANCE,
	PHASER,
	CHORUS,
	DELAY,
}

# volume globals
const VOLUME_DB_OFF : float = -60.0
const VOLUME_DB_ON : float = 0.0

# drunk fx thresholds
const DRUNK_FX_MIN : float = 0.0
const DRUNK_FX_LOW : float = 0.15
const DRUNK_FX_MED : float = 0.35
const DRUNK_FX_HIGH : float = 0.65
const DRUNK_FX_MAX : float = 1.0

# audio effect handlers
var stereo_enhancer_effect : AudioEffectStereoEnhance
var chorus_effect : AudioEffectChorus
var phaser_effect : AudioEffectPhaser
var delay_effect : AudioEffectDelay

# local drunkness variable
var drunk_effect_intensity : float


# ======================== #
# === Setting Controls === #
# ======================== #
func _ready():
	stereo_enhancer_effect = AudioServer.get_bus_effect(BUS.DRUNK_FX, FX.STEREO_ENHANCE)
	chorus_effect = AudioServer.get_bus_effect(BUS.DRUNK_FX, FX.CHORUS)
	phaser_effect = AudioServer.get_bus_effect(BUS.DRUNK_FX, FX.PHASER)
	delay_effect = AudioServer.get_bus_effect(BUS.DRUNK_FX, FX.DELAY)
	
	UserSettings.on_settings_updated.connect(update_audio_settings)
	GameStateManager.player_drunkness.on_drunkness_changed.connect(update_drunk_effects)


func update_audio_settings() -> void:
	AudioServer.set_bus_volume_linear(BUS.MASTER, UserSettings.master_volume)
	AudioServer.set_bus_volume_linear(BUS.MUSIC, UserSettings.music_volume)
	AudioServer.set_bus_volume_linear(BUS.SFX, UserSettings.sfx_volume)
	AudioServer.set_bus_volume_linear(BUS.AMBIENCE, UserSettings.ambience_volume)
	AudioServer.set_bus_volume_linear(BUS.UI, UserSettings.ui_volume)
	
	set_drunk_fx(UserSettings.disorienting_sounds_enabled)
	
	if is_instance_valid(player_sounds):
		player_sounds.burp_nastiness = UserSettings.burp_nastiness


func set_drunk_fx(enabled : bool) -> void:
	AudioServer.set_bus_effect_enabled(BUS.DRUNK_FX, FX.STEREO_ENHANCE, enabled)
	AudioServer.set_bus_effect_enabled(BUS.DRUNK_FX, FX.CHORUS, enabled)
	AudioServer.set_bus_effect_enabled(BUS.DRUNK_FX, FX.PHASER, enabled)
	AudioServer.set_bus_effect_enabled(BUS.DRUNK_FX, FX.DELAY, enabled)


# ========================= #
# === Drunkness Effects === #
# ========================= #
func update_drunk_effects(drunk_value : float = -1.0) -> void:
	drunk_effect_intensity = remap_drunkness(drunk_value) if drunk_value > 0.0 else drunk_effect_intensity
	
	#if drunk_effect_intensity > DRUNK_FX_LOW:
	update_stereo_enhance_fx(drunk_effect_intensity)
		
		#if drunk_effect_intensity > DRUNK_FX_MED:
	update_phaser_fx(drunk_effect_intensity)
	update_chorus_fx(drunk_effect_intensity)
			
			#if drunk_effect_intensity > DRUNK_FX_HIGH:
	update_delay_fx(drunk_effect_intensity)


func update_stereo_enhance_fx(value) -> void:
	var pan_value : float = remap(value, DRUNK_FX_LOW, DRUNK_FX_MAX, 0.5, 4.0)
	pan_value = clampf(pan_value, 0.75, 3.5)
	stereo_enhancer_effect.pan_pullout = pan_value


func update_phaser_fx(value) -> void:
	var rate_hz_value : float = remap(value, DRUNK_FX_HIGH, DRUNK_FX_MAX, 0.01, 0.5)
	rate_hz_value = clampf(rate_hz_value, 0.01, 0.5)
	phaser_effect.rate_hz = rate_hz_value
	
	var feedback_value : float = remap(value, DRUNK_FX_HIGH, DRUNK_FX_MAX, 0.1, 0.3)
	feedback_value = clampf(feedback_value, 0.1, 0.3)
	phaser_effect.feedback = feedback_value
	
	var depth_value : float = remap(value, DRUNK_FX_HIGH, DRUNK_FX_MAX, 0.1, 0.3)
	depth_value = clampf(depth_value, 0.1, 0.3)
	phaser_effect.depth = depth_value


func update_chorus_fx(value) -> void:
	var wet_value : float = remap(value, DRUNK_FX_MED, DRUNK_FX_MAX, 0.0, 0.6)
	wet_value = clampf(wet_value, 0.0, 0.6)
	chorus_effect.wet = wet_value
	
	var dry_value : float = DRUNK_FX_MAX - wet_value
	chorus_effect.dry = dry_value


func update_delay_fx(value) -> void:
	var dry_value = DRUNK_FX_MAX - (value * 0.15)
	delay_effect.dry = dry_value
	
	var tap_level : float = remap(value, DRUNK_FX_HIGH, DRUNK_FX_MAX, 0.0, 0.15)
	tap_level = clampf(tap_level, 0.0, 0.15)
	tap_level = linear_to_db(tap_level)
	delay_effect.tap1_level_db = tap_level
	delay_effect.tap2_level_db = tap_level
	
	var feedback_level : float = remap(value, DRUNK_FX_HIGH, DRUNK_FX_MAX, 0.0, 0.15)
	feedback_level = clampf(feedback_level, 0.0, 0.15)
	feedback_level = linear_to_db(feedback_level)
	delay_effect.feedback_level_db = feedback_level


func remap_drunkness(value : float) -> float:
	value = remap(
		value,
		GameStateManager.player_drunkness.min_drunkness,
		GameStateManager.player_drunkness.max_drunkness,
		DRUNK_FX_MIN,
		DRUNK_FX_MAX
	)
	value = clampf(value, DRUNK_FX_MIN, DRUNK_FX_MAX)
	return value


# ======================== #
# === Helper functions === #
# ======================== #
func fade_audio_in(node: Node, _target_volume_db : float = VOLUME_DB_ON, _fade_speed : float = 1.5) -> void:
	node.set("volume_db", VOLUME_DB_OFF)
	tween_volume_db(node, _target_volume_db, _fade_speed)


func fade_audio_out(node: Node, _fade_speed : float = 1.5) -> void:
	tween_volume_db(node, VOLUME_DB_OFF, _fade_speed)


func tween_volume_db(node: Node, _target_volume_db : float, _fade_speed : float = 1.5) -> void:
	if !is_audio_player(node):
		push_warning(
			str("AudioManager: fade_in_audio() cannot process node: ", 
			node, " has to be of type AudioStreamPlayer(/2D/3D)")
		)
		return
	
	var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "volume_db", _target_volume_db, _fade_speed)


func is_audio_player(node : Node) -> bool:
	var condition_met : bool = (
		node is AudioStreamPlayer
		or node is AudioStreamPlayer2D
		or node is AudioStreamPlayer3D
	)
	return condition_met
