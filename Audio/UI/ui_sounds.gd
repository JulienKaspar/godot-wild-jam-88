extends AudioStreamPlayer
class_name UI_Sounds

@export var start_game : AudioStream
@export var break_anticipation : AudioStream

@export var focus_element : AudioStreamRandomizer
@export var tab_change : AudioStreamRandomizer
@export var update_slider : AudioStreamRandomizer
@export var checkbox_on : AudioStreamRandomizer
@export var checkbox_off : AudioStreamRandomizer
@export var burp_sounds : AudioStreamRandomizer

@export var drunkness_up : AudioStream
@export var drunkness_down : AudioStream
@export var shake_impact : AudioStream

var game_started : bool = false

func _ready():
	if (AudioManager.ui_sounds == null):
		AudioManager.ui_sounds = self


func play_sound(_stream : AudioStream):
	if !is_instance_valid(_stream):
		push_warning(str("UI_Sounds: cannot play sound: ", _stream, " is no valid AudioStream resource"))
		return
	
	if GameStateManager.current_state == GameStateManager.GameState.Game:
		match _stream:
			drunkness_down, drunkness_up, shake_impact:
				self.stream = _stream
				self.play()
				return
	else:

		#print(stream)
		self.stream = _stream
		self.play()


func select_burps(intensity : float) -> void:
	var sum : float = burp_sounds.streams_count
	var mean : float = sum * intensity
	var center : int = round(mean)
	var max_dist : int = 3
	var max_prob : float = 1.0
	var min_prob : float = 0.5
	
	if intensity <= 0.0:
		min_prob = 0.0
		max_prob = 0.0
	
	for i in range(sum - 1):
		var diff : int = abs(i - center)
		var prob : float = remap(diff, 0, max_dist, max_prob, min_prob) if (diff <= max_dist) else 0.0
		burp_sounds.set_stream_probability_weight(i, prob)
	
	play_sound(burp_sounds.get_stream(center-1))
	
