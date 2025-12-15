extends HBoxContainer
class_name SFXVolumeSlider

@onready var number: Label = %Label2
@onready var slider: HSlider = %HSlider

func _ready() -> void:
	slider.value = UserSettings.sfx_volume
	number.text = str(UserSettings.sfx_volume)
	
func update_sensitivity(new_value: float) -> void:
	number.text = str(new_value)
	UserSettings.sfx_volume = new_value
