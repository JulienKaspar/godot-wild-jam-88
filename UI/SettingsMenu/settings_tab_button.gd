extends TextureButton
class_name SettingsTabButton

@export var focus_scale: float = 1.1
@export var focus_speed: float = 0.2

func _ready() -> void:
	focus_entered.connect(select)
	focus_exited.connect(deselect)

func select() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, 'scale', Vector2(focus_scale, focus_scale), focus_speed)
	z_index = 10
	
	
func deselect() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, 'scale', Vector2(1,1), focus_speed)
	z_index = 0
