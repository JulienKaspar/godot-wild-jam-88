extends TextureProgressBar
class_name DrunknessMeter

@export var frames: Array[Texture2D]
@export var base_framerate: float = 6
@export var base_frame_sprite: Texture2D
@export var flashing_frame_sprite: Texture2D

var flash_time_elapsed: float = 0
var flash_time: float = 0.15
var flash_scale: float = 1.06
var flash_scale_duration: float = 0.07
var flashing: bool

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
		
	if flashing:
		flash_time_elapsed += delta
	
	if flash_time_elapsed > flash_time:
		flash_time_elapsed = 0
		flashing = false
		texture_over = base_frame_sprite

func flash() -> void:
	flashing = true
	texture_over = flashing_frame_sprite
	var flash_tween: Tween = create_tween()
	flash_tween.tween_property(self, 'scale', Vector2(flash_scale, flash_scale), flash_scale_duration)
	flash_tween.tween_property(self, 'scale', Vector2(1,1), flash_scale_duration / 2)
