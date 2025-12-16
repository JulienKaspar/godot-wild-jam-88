extends AudioStreamPlayer
class_name UI_Sounds

@export var start_game : AudioStream
@export var hover : AudioStream
@export var select : AudioStream
@export var cancel : AudioStream

func play_sound(_stream : AudioStream):
	if !is_instance_valid(_stream):
		push_warning(str("UI_Sounds: cannot play sound: ", _stream, " is no valid AudioStream resource"))
		return
	
	self.stream = _stream
	self.play()
