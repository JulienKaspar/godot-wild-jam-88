extends TextureProgressBar
class_name DrunknessMeter

@export var frames: Array[Texture2D]
@export var excited_frames: Array[Texture2D]
@export var base_framerate: float = 6
@export var excited_framerate: float = 20
@export var base_frame_sprite: Texture2D
@export var flashing_frame_sprite: Texture2D

var flash_time_elapsed: float = 0
var flash_time: float = 0.2
var flash_scale: float = 1.2
var flash_scale_duration: float = 0.07
var flashing: bool

var excited_duration: float = 1.2
var excited_elapsed: float
var excited: bool



var frame_time: float
var frame_time_elapsed: float
var index: int = 0
func _ready() -> void:
	frame_time = 1 / base_framerate

func _process(delta: float) -> void:
	frame_time_elapsed += delta
	if frame_time_elapsed > frame_time:
		frame_time_elapsed = 0
		texture_progress = frames[index % frames.size()] if !excited else excited_frames[index % excited_frames.size()]
		index += 1
		
	if flashing:
		flash_time_elapsed += delta
		
		frame_time = 1 / base_framerate
	
	if excited:
		excited_elapsed += delta
		frame_time = 1 / excited_framerate
	
	if flash_time_elapsed > flash_time:
		flash_time_elapsed = 0
		flashing = false
		texture_over = base_frame_sprite
		
	if excited_elapsed > excited_duration:
		excited = false
		excited_elapsed = 0

func flash() -> void:
	flashing = true
	excited = true
	texture_over = flashing_frame_sprite
	var flash_tween: Tween = create_tween()
	flash_tween.tween_property(self, 'scale', Vector2(flash_scale, flash_scale), flash_scale_duration)
	flash_tween.tween_property(self, 'scale', Vector2(1,1), flash_scale_duration)
	
	
	
