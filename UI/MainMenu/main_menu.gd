extends PanelContainer
class_name MainMenu

@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var settings_menu: Button = $MarginContainer/VBoxContainer/SettingsMenu
@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton

signal settings_menu_button_pressed()
signal start_button_pressed()

func _ready() -> void:
	start_button.pressed.connect(handle_start_button_pressed)
	settings_menu.pressed.connect(handle_settings_menu_button_pressed)
	exit_button.pressed.connect(handle_exit_button_pressed)
	
	print(ProjectSettings.get_setting("sensitivity", 1))
	
func handle_start_button_pressed() -> void:
	start_button_pressed.emit()
	
func handle_settings_menu_button_pressed() -> void:
	settings_menu_button_pressed.emit()

func handle_exit_button_pressed() -> void:
	get_tree().quit(0)
