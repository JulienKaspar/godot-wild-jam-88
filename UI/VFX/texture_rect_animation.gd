extends TextureRect
class_name TextureRectAnimaton

@export var always_play: bool = false
@export var framerate: int
@export var frames: Array[Texture2D]

var time_elapsed: float
var index: int
var limited_amount: int


func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed > 1 / float(framerate) && visible:
		index += 1
		time_elapsed = 0
		update_frame()
		
	if !always_play && limited_amount != null:
		if index > limited_amount:
			hide()
			
func update_frame() -> void:
	texture = frames[index % frames.size()]

func play_frames(amount_of_frames: int) -> void:
	index = 0
	limited_amount = amount_of_frames
	show()
