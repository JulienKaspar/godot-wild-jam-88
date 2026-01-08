extends TextureButton
class_name AchievementMenuButton

var scale_speed: float = 0.1
var hovered_scale: float = 1.1

func _ready() -> void:
	mouse_entered.connect(grab_focus)
	mouse_exited.connect(release_focus)
	
	focus_entered.connect(on_selected)
	focus_exited.connect(on_deselected)
	
	pivot_offset = Vector2(size.x / 2, size.y / 2)

	
func on_selected() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, "scale", Vector2(hovered_scale, hovered_scale), scale_speed)
	
func on_deselected() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, "scale", Vector2(1,1), scale_speed)
