extends GameScreen
class_name PauseMenu

@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var exit_button: Button = %ExitButton
@onready var restart_button: Button = %RestartLevelButton

signal on_settings_opened()
signal on_main_menu_opened()
signal on_restarted()

func _ready() -> void:
	resume_button.pressed.connect(func(): GameStateManager.toggle_pause())
	settings_button.pressed.connect(func(): on_settings_opened.emit())
	main_menu_button.pressed.connect(func(): on_main_menu_opened.emit())
	restart_button.pressed.connect(func(): on_restarted.emit())
	exit_button.pressed.connect(func(): get_tree().quit(0))
	
func open() -> void:
	show()
	resume_button.grab_focus()
	
func close() -> void:
	hide()
