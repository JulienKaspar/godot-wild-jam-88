# audio_manager.gd
# ================
# stores global audio information
# handles audio settings
extends Node

enum BUS {
	MASTER = 0,
	MUSIC = 1,
	SFX = 2,
	AMBIENCE = 3,
	UI = 4,
}

# TODO: Ensure this is consistent with audio_bus_layout
# NOTE: Dynamically load / replace with audio bus layout resource?
enum FX {
	STEREO_ENHANCE = 0,
	CHORUS = 1,
	PHASER = 2,
	DELAY = 3,
}

var music_manager : MusicManager
var ui_sounds : UI_Sounds
var player_sounds : PlayerSounds

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
