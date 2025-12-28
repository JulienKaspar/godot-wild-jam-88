extends HBoxContainer
class_name MasterVolumeSlider

@onready var number: Label = %Label2
@onready var slider: HSlider = %HSlider

func _ready() -> void:
	slider.value = UserSettings.master_volume
	number.text = str(UserSettings.master_volume)
	
func update_sensitivity(new_value: float) -> void:
	number.text = str(new_value)
	UserSettings.master_volume = new_value
