extends HBoxContainer
class_name UIVolumeSlider

@onready var number: Label = %Label2
@onready var slider: HSlider = %HSlider

func _ready() -> void:
	slider.value = UserSettings.ui_volume
	number.text = str(UserSettings.ui_volume)
	
func update_sensitivity(new_value: float) -> void:
	number.text = str(new_value)
	UserSettings.ui_volume = new_value
