extends SpotLight3D

func _process(_delta: float) -> void:
	visible = !UserSettings.strobe_lights
