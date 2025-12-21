#user_settings.gd (autoload)
extends Node



var sensitivity: float = 1

@warning_ignore("unused_signal")
signal on_settings_updated()
signal on_font_toggled(readability_font: bool)

#volume
var master_volume: float = 1
var music_volume: float = .6
var sfx_volume: float = 1
var ambience_volume : float = 1
var ui_volume: float = 1
var disorienting_sounds_enabled: bool = true
var burp_nastiness: float = 0.5:
	set(value):
		burp_nastiness = value
		AudioManager.ui_sounds.select_burps(value)


#accesibility / general
var fail_state: bool = false
var loading_speed: float = 1
var text_scrolling_speed:float = 1
var easy_mode: bool = false
var readability_font: bool = false: 
	set(value):
		on_font_toggled.emit(value)
		readability_font = value
	
#visual
var drunk_visual_effect_intensity: float = 1
var strobe_lights: bool = true
var windowed_mode: bool = false
var camera_shake_modifier: float = 1
#control
var controller_rumble: bool = true

#audio
#Controls: 
#pic of controller
#pic of keyboard

#Visual: 
#resolution arrow thing
