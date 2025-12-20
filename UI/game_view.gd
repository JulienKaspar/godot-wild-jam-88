extends Node
@onready var main_menu: MainMenu = %MainMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var hud: HUD = %HUD
@onready var menu_displayer: Control = %MenuDisplayer
@onready var dialogue_system: Control = %DialogueSystem
@export var default_font_theme: Theme
@export var readability_font_theme: Theme

var game_started: bool = false

func _ready() -> void:
	main_menu.settings_menu_button_pressed.connect(handle_setting_menu_opened)
	main_menu.start_button_pressed.connect(handle_game_started)
	GameStateManager.on_paused.connect(show_settings_menu)
	GameStateManager.on_unpaused.connect(show_game_ui)
	UserSettings.on_font_toggled.connect(switch_font)
	settings_menu.on_back.connect(handle_back_button_pressed)
	main_menu.start_button.grab_focus.call_deferred()
	
func switch_font(readability_font: bool) -> void:
	menu_displayer.theme = readability_font_theme if readability_font else default_font_theme
	menu_displayer.queue_redraw()
	
	dialogue_system.theme = readability_font_theme if readability_font else default_font_theme
	dialogue_system.queue_redraw()
	
	
func handle_setting_menu_opened() -> void:
	main_menu.hide()
	settings_menu.show()
	hud.hide()
	settings_menu.open()

func handle_back_button_pressed() -> void:
	if !game_started:
		handle_main_menu_opened()
	else:
		show_game_ui()
	
func handle_main_menu_opened() -> void:
	main_menu.show()
	settings_menu.hide()
	hud.hide()
	main_menu.start_button.grab_focus.call_deferred()

	# handle hiding game here potentially
#
func handle_game_started() -> void:
	main_menu.hide()
	settings_menu.hide()
	hud.show()
	game_started = true
	
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
	
