extends TextureRect
class_name SpeechBubbleAnimation
@export var frames: Array[Texture2D]
@export var framerate: float = 0.5
@export var wobble_times: int = 5
@export var speech_max_wobble_deviation: float = 10
@export var speech_wobble_duration: float = 0.1
var time_elapsed_on_frame: float = 0


func _process(delta: float) -> void:
	time_elapsed_on_frame += delta
	if time_elapsed_on_frame > 1 / framerate:
		switch_frames()



func switch_frames() -> void:
	time_elapsed_on_frame = 0
	position = Vector2(0,0)
	if texture == frames[0]:
		texture = frames[1]
		return
	texture = frames[0]
	

func wobble_speech() -> void:
	var speech_wobble_tween: Tween = create_tween()
	for i in wobble_times:
		var x_random: float = randf_range(-speech_max_wobble_deviation, speech_max_wobble_deviation)
		var y_random: float = randf_range(-speech_max_wobble_deviation, speech_max_wobble_deviation)
		speech_wobble_tween.tween_property(self, "position", self.position + 
		Vector2(
			x_random, 
			y_random),
			speech_wobble_duration)
