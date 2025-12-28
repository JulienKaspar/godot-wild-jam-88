extends HBoxContainer
class_name MusicVolumeSlider

@onready var number: Label = %Label2
@onready var slider: HSlider = %HSlider

func _ready() -> void:
	slider.value = UserSettings.music_volume
	number.text = str(UserSettings.music_volume)
	
func update_sensitivity(new_value: float) -> void:
	number.text = str(new_value)
	UserSettings.music_volume = new_value
