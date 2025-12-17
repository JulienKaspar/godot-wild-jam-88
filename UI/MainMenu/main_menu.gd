extends PanelContainer
class_name MainMenu
@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton

signal settings_menu_button_pressed()
signal start_button_pressed()

func _ready() -> void:
	settings_button.pressed.connect(handle_settings_menu_button_pressed)
	start_button.pressed.connect(handle_start_button_pressed)
	exit_button.pressed.connect(handle_exit_button_pressed)

func handle_start_button_pressed() -> void:
	start_button_pressed.emit()
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.start_game)
	GameStateManager.start_game()
	
func handle_settings_menu_button_pressed() -> void:
	settings_menu_button_pressed.emit()

func handle_exit_button_pressed() -> void:
	get_tree().quit(0)

# Sound
@onready var title_screen_ambience : AudioStreamPlayer = %TitleScreenAmbience

func enter_menu_ambience():
	AudioManager.fade_audio_in(title_screen_ambience, 0.0, 2.5)
	title_screen_ambience.play()
