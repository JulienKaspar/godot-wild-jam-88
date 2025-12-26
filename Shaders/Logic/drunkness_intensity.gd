extends ColorRect

func _process(_delta: float) -> void:
	update_drunk_visual_effect()

func update_drunk_visual_effect() -> void:
	var effect_intensity: float = 0.05
	var sobriety_threshold: float = 2.0
	var current_drunkness = GameStateManager.player_drunkness.current_drunkness
	var drunk_effect_intensity = max(current_drunkness, sobriety_threshold) * effect_intensity * clampf(UserSettings.drunk_visual_effect_intensity, 0.1, 1)
	material.set('shader_parameter/drunkness', drunk_effect_intensity)
	var bleak_effect_intensity = clampf(1. - (current_drunkness / sobriety_threshold), 0., 1.)
	material.set('shader_parameter/bleakness', bleak_effect_intensity)
