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
var ui_sounds : UI_Sounds = UI_Sounds.new()

# Fading audio
func fade_audio(node: Node, _target_volume_linear : float = -1.0, _fade_speed : float = 1.5) -> void:
	# Check for correct use
	if !_is_audio_player(node):
		push_warning(str("AudioManager: fade_in_audio() cannot process node: ", node, " has to be of type AudioStreamPlayer(/2D/3D)"))
		return
	elif _target_volume_linear < 0.0:
		push_warning("AudioManager: fade_in_audio() requires _target_volume_linear to be set (0.0 for fade out, > 0.0 for fade in)")
		return
	
	# Ensure node's volume is off if target is on
	if _target_volume_linear > 0.0:
		node.set("volume_db", -60.0)
	
	# Tween audio to target volume
	var tween : Tween = create_tween()
	tween.tween_property(node, "volume_db", linear_to_db(_target_volume_linear), _fade_speed)

func _is_audio_player(node : Node) -> bool:
	var is_audio_player : bool = (
		node is AudioStreamPlayer
		or node is AudioStreamPlayer2D
		or node is AudioStreamPlayer3D
	)
	
	return is_audio_player
