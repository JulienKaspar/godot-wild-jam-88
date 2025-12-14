extends PanelContainer
class_name SettingsMenu

@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var sensitivity_number: Label = %SensitivityNumber
@onready var main_menu_button: Button = %MainMenuButton

signal main_menu_button_pressed()

func _ready() -> void:
	
	sensitivity_slider.value_changed.connect(handle_sensitivity_slider_changed)
	main_menu_button.pressed.connect(handle_main_menu_button_pressed)
	
	sensitivity_number.text = str(ProjectSettings.get_setting("sensitivity", 1))
	sensitivity_slider.value = ProjectSettings.get_setting("sensitivity", 1)

func handle_sensitivity_slider_changed(value: float) -> void:
	ProjectSettings.set_setting("sensitivity", sensitivity_slider.value)
	sensitivity_number.text = str(value)

func handle_main_menu_button_pressed() -> void:
	main_menu_button_pressed.emit()
