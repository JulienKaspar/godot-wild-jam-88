extends TextureRect
class_name TextureRectAnimaton

@export var framerate: int
@export var frames: Array[Texture2D]

var time_elapsed: float
var index: int

func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed > 1 / float(framerate):
		index += 1
		time_elapsed = 0
		update_frame()
		
func update_frame() -> void:
	texture = frames[index % frames.size()]
