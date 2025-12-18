extends Button

@export var scale_factor: float = 1.2

func _ready() -> void:
	mouse_entered.connect(make_big)
	mouse_exited.connect(make_small)
	
	focus_entered.connect(make_big)
	focus_exited.connect(make_small)

func make_big() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, "scale", Vector2(scale_factor, scale_factor), 0.2)

func make_small() -> void:
	var size_tween: Tween = create_tween()
	size_tween.tween_property(self, 'scale', Vector2(1, 1), 0.2)
