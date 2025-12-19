#user_settings.gd (autoload)
extends Node

var sensitivity: float = 1

@warning_ignore("unused_signal")
signal on_settings_updated()

#volume
var master_volume: float = 1
var music_volume: float = 1
var sfx_volume: float = 1
var ambience_volume : float = 1
var ui_volume: float = 1

var disorienting_sounds_enabled: bool = true
var burp_nastiness: float = 0.5

#accesibility / general
var fail_state: bool = false
var loading_speed: float = 1
var text_scrolling_speed:float = 1

#visual
var drunk_visual_effect_intensity: float = 1
var strobe_lights: bool = true
var windowed_mode: bool = false

#control
var controller_rumble: bool = true

#audio
