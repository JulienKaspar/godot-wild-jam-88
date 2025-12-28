extends TextureButton
class_name SettingsTabButton

@export var focus_scale: float = 1.15
@export var focus_speed: float = 0.2
@export var focused_margin_value: int = 35
@export var hovered_scale: float = 1.06


func _ready() -> void:
	focus_entered.connect(select)
	focus_exited.connect(deselect)
	
	mouse_entered.connect(hover)
	mouse_exited.connect(unhover)
	
func hover() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, 'scale', Vector2(hovered_scale, hovered_scale), focus_speed)
	z_index = 10

func unhover() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, 'scale', Vector2(1,1), focus_speed)
	z_index = 0

func select() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, 'scale', Vector2(focus_scale, focus_scale), focus_speed)
	z_index = 10
	enable_side_margin()
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.tab_change)
	
func deselect() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, 'scale', Vector2(1,1), focus_speed)
	z_index = 0
	disable_side_margin()

func disable_side_margin() -> void:
	var parent: Node = get_parent()
	if parent is MarginContainer:
		var margin_container: MarginContainer = parent as MarginContainer
		margin_container.remove_theme_constant_override("margin_left")
		margin_container.remove_theme_constant_override("margin_right")

func enable_side_margin() -> void:
	var parent: Node = get_parent()
	if parent is MarginContainer:
		var margin_container: MarginContainer = parent as MarginContainer
		margin_container.add_theme_constant_override("margin_left", focused_margin_value)
		margin_container.add_theme_constant_override("margin_right", focused_margin_value)
