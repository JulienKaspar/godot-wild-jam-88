extends Label
class_name SettingsLabel

@export var focus_color: Color
@export var focus_scale: float = 1.2
@export var focus_scale_speed: float = 0.15
const regular_color: Color = Color.WHITE


func focus() -> void:
	add_theme_color_override("font_color", focus_color)
	
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, "scale", Vector2(focus_scale, focus_scale), focus_scale_speed)
	add_theme_constant_override("outline_size", 30) 

	
func unfocus() -> void:
	add_theme_color_override("font_color", Color.WHITE)
	scale = Vector2(1,1)
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, "scale", Vector2(1,1), focus_scale_speed)
	add_theme_constant_override("outline_size", 0) 
