extends PanelContainer
class_name MainMenu

signal settings_menu_button_pressed()
signal start_button_pressed()

func handle_start_button_pressed() -> void:
	start_button_pressed.emit()
	
func handle_settings_menu_button_pressed() -> void:
	settings_menu_button_pressed.emit()

func handle_exit_button_pressed() -> void:
	get_tree().quit(0)

func parralax() -> void:
	pass
