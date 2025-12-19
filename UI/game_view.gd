extends Node
@onready var main_menu: MainMenu = %MainMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var hud: HUD = %HUD

func _ready() -> void:
	main_menu.settings_menu_button_pressed.connect(handle_setting_menu_opened)
	main_menu.start_button_pressed.connect(handle_game_started)
	GameStateManager.on_paused.connect(show_settings_menu)
	GameStateManager.on_unpaused.connect(show_game_ui)
	
func handle_setting_menu_opened() -> void:
	main_menu.hide()
	settings_menu.show()
	hud.hide()
	settings_menu.open()
	
func handle_main_menu_opened() -> void:
	main_menu.show()
	settings_menu.hide()
	hud.hide()
	# handle hiding game here potentially
#
func handle_game_started() -> void:
	main_menu.hide()
	settings_menu.hide()
	hud.show()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameStateManager.toggle_pause()

func show_settings_menu() -> void:
	main_menu.hide()
	settings_menu.show()
	hud.hide()
	
func show_game_ui() -> void:
	main_menu.hide()
	settings_menu.hide()
	hud.show() 	
