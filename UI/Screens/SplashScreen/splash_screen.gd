extends GameScreen
class_name SplashScreen

signal on_completed()
@onready var texture_rect: TextureRect = %TextureRect

var splash_screen_fade_in_time: float = 3
var splash_screen_display_time_total: float = 6.0
var splash_screen_fade_out_time: float = 2
var time_elapsed: float = 0.0
var fade_out_started: bool = false

func _ready() -> void:
	var opacity_tween: Tween = create_tween()
	opacity_tween.tween_property(texture_rect, "modulate:a", 1, splash_screen_fade_in_time)

func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed > splash_screen_display_time_total && !fade_out_started:
		fade_out()

func fade_out() -> void:
	fade_out_started = true
	var opacity_tween: Tween = create_tween()
	opacity_tween.tween_property(texture_rect, "modulate:a", 0, splash_screen_fade_out_time)
	opacity_tween.finished.connect(func():
		on_completed.emit())

func open() -> void:
	show()
	
func close() -> void:
	hide()
