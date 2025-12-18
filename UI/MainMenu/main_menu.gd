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
	
	start_button.grab_focus.call_deferred()
	enter_menu_sounds()

func handle_start_button_pressed() -> void:
	start_button_pressed.emit()
	exit_menu_sounds()
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.start_game)
	GameStateManager.start_game()
	
func handle_settings_menu_button_pressed() -> void:
	settings_menu_button_pressed.emit()

func handle_exit_button_pressed() -> void:
	get_tree().quit(0)

# Sound
@onready var title_screen_ambience : AudioStreamPlayer = %TitleScreenAmbience
@onready var theme_music_muted : AudioStreamPlayer = %ThemeMusicMuted

func enter_menu_sounds():
	## NOTE: WHY DOES THIS LINE NOT WORK??
	#AudioManager.fade_audio_in(title_screen_ambience, 0.0, 1.5)
	
	## BUT THIS DOES?
	title_screen_ambience.volume_db = AudioManager._VOLUME_DB_OFF
	var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(title_screen_ambience, "volume_db", 0.0, 2.5)
	title_screen_ambience.play()

func exit_menu_sounds():
	AudioManager.fade_audio_out(title_screen_ambience, 2.5)
	AudioManager.fade_audio_out(theme_music_muted, 2.5)
	
