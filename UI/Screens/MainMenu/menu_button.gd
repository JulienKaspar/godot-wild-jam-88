extends Button
@export var scale_factor: float = 1.2

func _ready() -> void:
	mouse_entered.connect(make_big)
	mouse_exited.connect(make_small)
	
	focus_entered.connect(make_big)
	focus_exited.connect(make_small)
	
	mouse_entered.connect(grab_focus)
	
	pivot_offset = Vector2(size.x / 2, size.y / 2)

func make_big() -> void:
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.focus_element)
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, "scale", Vector2(scale_factor, scale_factor), 0.2)
	add_theme_constant_override("outline_size", 30) 

func make_small() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, 'scale', Vector2(1, 1), 0.2)
	add_theme_constant_override("outline_size", 0) 
	release_focus()
