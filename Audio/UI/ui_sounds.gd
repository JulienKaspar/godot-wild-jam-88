extends AudioStreamPlayer
class_name UI_Sounds

@export var start_game : AudioStream

@export var focus_element : AudioStream
@export var tab_change : AudioStream
@export var update_slider : AudioStream
@export var check_box : AudioStream
@export var uncheck_box : AudioStream

@export var drunkness_up : AudioStream
@export var drunkness_down : AudioStream

func _ready():
	if (AudioManager.ui_sounds == null):
		AudioManager.ui_sounds = self

func play_sound(_stream : AudioStream):
	if !is_instance_valid(_stream):
		push_warning(str("UI_Sounds: cannot play sound: ", _stream, " is no valid AudioStream resource"))
		return
	
	self.stream = _stream
	self.play()
