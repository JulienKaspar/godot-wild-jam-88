extends PanelContainer
class_name SettingsMenu

@onready var main_menu_button: Button = %MainMenuButton

signal main_menu_button_pressed()

func _ready() -> void:
	main_menu_button.pressed.connect(handle_main_menu_button_pressed)

func handle_main_menu_button_pressed() -> void:
	main_menu_button_pressed.emit()
