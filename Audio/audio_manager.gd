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
