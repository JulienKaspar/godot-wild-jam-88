extends GameScreen
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

func open() -> void:
	show()
	start_button.grab_focus.call_deferred()
	GameStateManager.current_state = GameStateManager.GameState.MainMenu
	enter_menu_sounds()
	

func close() -> void:
	hide()
	exit_menu_sounds()

# Sound
@onready var title_screen_ambience : AudioStreamPlayer = %TitleScreenAmbience
@onready var theme_music_muted : AudioStreamPlayer = %ThemeMusicMuted

func enter_menu_sounds():
	AudioManager.set_credits_settings(false)
	title_screen_ambience.bus = AudioServer.get_bus_name(AudioManager.BUS.AMBIENCE)
	theme_music_muted.bus = AudioServer.get_bus_name(AudioManager.BUS.MUSIC)
	
	title_screen_ambience.volume_db = AudioManager.VOLUME_DB_OFF
	#theme_music_muted.volume_db = AudioManager.VOLUME_DB_OFF
	
	var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(title_screen_ambience, "volume_db", 0.0, 2.0)
	#tween.tween_property(theme_music_muted, "volume_db", 0.0, 1.0)
	
	title_screen_ambience.play()
	#theme_music_muted.play()

func exit_menu_sounds():
	AudioManager.fade_audio_out(title_screen_ambience, 2.5)
	AudioManager.fade_audio_out(theme_music_muted, 2.5)
