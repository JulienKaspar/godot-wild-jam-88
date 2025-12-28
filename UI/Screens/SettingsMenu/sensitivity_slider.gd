extends HBoxContainer
class_name SensitivitySlider

@onready var sensitivity_number: Label = %SensitivityNumber
@onready var sensitivity_slider: HSlider = %SensitivitySlider

func _ready() -> void:
	sensitivity_slider.value = UserSettings.sensitivity
	sensitivity_number.text = str(UserSettings.sensitivity)
	
func update_sensitivity(new_value: float) -> void:
	sensitivity_number.text = str(new_value)
	UserSettings.sensitivity = new_value
