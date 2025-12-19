extends HBoxContainer
class_name SliderSetting
@export var setting_name: String
@export var property_name: StringName
@export var top_focus_target: Control
@onready var slider: TextureSlider = %HSlider

func _ready() -> void:
	set_top_target.call_deferred(top_focus_target)
	slider.label.text = setting_name
	slider.value = UserSettings.get(property_name)
	slider.value_changed.connect(set_user_setting_value)
	mouse_entered.connect(slider.grab_focus)


func set_top_target(control: Control) -> void:
	if top_focus_target != null:
		slider.focus_neighbor_top = control.get_path()

func set_user_setting_value(new_value) -> void:
	UserSettings.set(property_name, new_value)
	UserSettings.on_settings_updated.emit()
