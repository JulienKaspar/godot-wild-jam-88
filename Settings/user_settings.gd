#user_settings.gd (autoload)
extends Node

var sensitivity: float = 1

signal on_settings_updated()

#volume
var master_volume: float = 1
var music_volume: float = 1
var sfx_volume: float = 1
var ambience_volume : float = 1
var ui_volume: float = 1

var disorienting_sounds_enabled: bool = true
var burp_nastiness: float = 1

#accesibility / general
var fail_state: bool = false
var loading_speed: float = 1

#visual
var drunk_visual_effect_intensity: float = 1
var strobe_lights: bool = true

#audio
