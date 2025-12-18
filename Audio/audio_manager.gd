# audio_manager.gd
# ================
# stores global audio information
# handles audio settings
extends Node

var music_manager : MusicManager
var ui_sounds : UI_Sounds
var player_sounds : PlayerSounds

const DRUNK_AUDIO_BUS_LAYOUT : AudioBusLayout = preload("uid://c6p02v462orsm")

# TODO: Ensure this is consistent with audio_bus_layout
# NOTE: Dynamically load / replace with audio bus layout resource?
enum BUS {
	MASTER,
	DRUNK_FX,
	MUSIC,
	SFX,
	AMBIENCE,
	UI,
	PLAYER
}


func _init():
	AudioServer.set_bus_layout(DRUNK_AUDIO_BUS_LAYOUT)

func _ready():
	GameStateManager.player_drunkness.on_drunkness_changed.connect(_update_drunk_effects)
	stereo_enhancer_effect = AudioServer.get_bus_effect(BUS.DRUNK_FX, FX.STEREO_ENHANCE)
	chorus_effect = AudioServer.get_bus_effect(BUS.DRUNK_FX, FX.CHORUS)
	phaser_effect = AudioServer.get_bus_effect(BUS.DRUNK_FX, FX.PHASER)
	delay_effect = AudioServer.get_bus_effect(BUS.DRUNK_FX, FX.DELAY)



#region VOLUME_CONTROL
const _VOLUME_DB_OFF := -60.0
func fade_audio_in(node: Node, _target_volume_db : float = 0.0, _fade_speed : float = 1.5) -> void:
	node.set("volume_db", _VOLUME_DB_OFF)
	tween_volume_db(node, _target_volume_db, _fade_speed)
	
func fade_audio_out(node: Node, _fade_speed : float = 1.5) -> void:
	tween_volume_db(node, _VOLUME_DB_OFF, _fade_speed)
	
func tween_volume_db(node: Node, _target_volume_db : float, _fade_speed : float = 1.5) -> void:
	# Check for correct use
	if !_is_audio_player(node):
		push_warning(str("AudioManager: fade_in_audio() cannot process node: ", node, " has to be of type AudioStreamPlayer(/2D/3D)"))
		return
	
	# Tween audio to target volume
	var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "volume_db", _target_volume_db, _fade_speed)
	

func _is_audio_player(node : Node) -> bool:
	var is_audio_player : bool = (
		node is AudioStreamPlayer
		or node is AudioStreamPlayer2D
		or node is AudioStreamPlayer3D
	)
	
	return is_audio_player
#endregion VOLUME_CONTROL



#region DRUNK_FX
enum FX {
	STEREO_ENHANCE = 0,
	CHORUS = 1,
	PHASER = 2,
	DELAY = 3,
}

const DRUNK_FX_LOW : float = 0.1
const DRUNK_FX_MED : float = 0.35
const DRUNK_FX_HIGH : float = 0.75

var stereo_enhancer_effect : AudioEffectStereoEnhance
var chorus_effect : AudioEffectChorus
var phaser_effect : AudioEffectPhaser
var delay_effect : AudioEffectDelay

func _update_drunk_effects(drunk_value) -> void:
	drunk_value = _remap_drunk_value(drunk_value)
	
	_update_stereo_enhance_fx(drunk_value)
	_update_phaser_fx(drunk_value)
	_update_chorus_fx(drunk_value)
	
func _update_stereo_enhance_fx(value) -> void:
	var pan_value : float = remap(value, DRUNK_FX_LOW, 1.0, 1.0, 4.0)
	pan_value = clampf(pan_value, 1.0, 4.0)
	stereo_enhancer_effect.pan_pullout = pan_value
	
func _update_delay_fx(value) -> void:
	var dry_value = 1.0 - value * 0.25
	delay_effect.dry = dry_value
	
	var tap_level : float = remap(value, DRUNK_FX_HIGH, 1.0, 0.0, 0.25)
	tap_level = clampf(tap_level, 0.0, 2.5)
	tap_level = linear_to_db(tap_level)
	delay_effect.tap1_level_db = tap_level
	delay_effect.tap2_level_db = tap_level
	
	var feedback_level : float = remap(value, DRUNK_FX_HIGH, 1.0, 0.0, 0.25)
	feedback_level = clampf(feedback_level, 0.0, 0.25)
	feedback_level = linear_to_db(feedback_level)
	delay_effect.feedback_level_db = feedback_level
	
func _update_phaser_fx(value) -> void:
	var feedback_value : float = remap(value, DRUNK_FX_HIGH, 1.0, 0.1, 0.4)
	feedback_value = clampf(feedback_value, 0.1, 0.4)
	phaser_effect.feedback = feedback_value
	
	var rate_hz_value : float = remap(value, DRUNK_FX_HIGH, 1.0, 0.01, 5.0)
	rate_hz_value = clampf(rate_hz_value, 0.01, 5.0)
	phaser_effect.rate_hz = rate_hz_value
	
	var depth_value : float = remap(value, DRUNK_FX_HIGH, 1.0, 0.1, 0.3)
	depth_value = clampf(depth_value, 0.1, 0.3)
	phaser_effect.depth = depth_value
	
func _update_chorus_fx(value) -> void:
	var dry_value : float = 1.0 - value * 0.5
	chorus_effect.dry = dry_value
	
	var wet_value : float = remap(value, DRUNK_FX_MED, 1.0, 0.0, 0.7)
	wet_value = clampf(wet_value, 0.0, 0.7)
	chorus_effect.wet = wet_value

func _remap_drunk_value(value : float) -> float:
	value = remap(
		value, 
		GameStateManager.player_drunkness.min_drunkness, # min input
		GameStateManager.player_drunkness.max_drunkness, # max input
		0.0,# min output
		1.0 # max output
	)
	value = clampf(value, 0.0, 1.0)
	return value
	
#endregion DRUNK_FX
