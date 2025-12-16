extends TextureProgressBar
class_name DrunknessMeter

@export var frames: Array[Texture2D]
@export var base_framerate: float = 6
var frame_time: float
var frame_time_elapsed: float
var index: int = 0
func _ready() -> void:
	frame_time = 1 / base_framerate

func _process(delta: float) -> void:
	frame_time_elapsed += delta
	if frame_time_elapsed > frame_time:
		frame_time_elapsed = 0
		texture_progress = frames[index % frames.size()]
		index += 1
