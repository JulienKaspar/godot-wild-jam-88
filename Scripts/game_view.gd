extends Node
@onready var main_menu: MainMenu = %MainMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu

func _ready() -> void:
	main_menu.settings_menu_button_pressed.connect(handle_setting_menu_opened)
	settings_menu.main_menu_button_pressed.connect(handle_main_menu_opened)
	
func handle_setting_menu_opened() -> void:
	main_menu.hide()
	settings_menu.show()
	
func handle_main_menu_opened() -> void:
	main_menu.show()
	settings_menu.hide()
	# handle hiding game here potentially
