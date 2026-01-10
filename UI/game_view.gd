extends Node
@onready var main_menu: MainMenu = %MenuDisplayer/%MainMenu
@onready var settings_menu: SettingsMenu = %MenuDisplayer/%SettingsMenu
@onready var credits_screen: CreditScreen = %MenuDisplayer/%CreditScreen
@onready var hud: HUD = %MenuDisplayer/%HUD
@onready var schmear_frame: TextureRect = %MenuDisplayer/%SchmearFrame
@onready var wasted_screen: WastedScreen = %MenuDisplayer/%WastedScreen
@onready var menu_displayer: MenuDisplayer = %MenuDisplayer
@onready var pause_menu: PauseMenu = %MenuDisplayer/%PauseMenu
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@export var default_font_theme: Theme
@export var readability_font_theme: Theme

var game_started: bool = false
func _ready() -> void:
	connect_signals.call_deferred()
	
func connect_signals() -> void:
	main_menu.settings_menu_button_pressed.connect(show_settings_menu)
	main_menu.start_button_pressed.connect(handle_game_started)
	main_menu.achievement_button.pressed.connect(handle_game_started)
	GameStateManager.on_unpaused.connect(show_game_ui)
	GameStateManager.show_credits.connect(end_credits)
	UserSettings.on_font_toggled.connect(switch_font)
	settings_menu.on_back.connect(handle_back_button_pressed)
	main_menu.start_button.grab_focus.call_deferred()
	GameStateManager.show_wasted_screen.connect(show_wasted_screen)
	wasted_screen.on_continued.connect(show_game_ui)
	pause_menu.on_main_menu_opened.connect(show_main_menu)
	pause_menu.on_restarted.connect(GameStateManager.reset_level)
	pause_menu.on_settings_opened.connect(show_settings_menu)
	
func switch_font(readability_font: bool) -> void:
	menu_displayer.theme = readability_font_theme if readability_font else default_font_theme
	menu_displayer.queue_redraw()
	DialogueSystem.dialogue_display.theme = readability_font_theme if readability_font else default_font_theme
	DialogueSystem.dialogue_display.queue_redraw()
	
func show_settings_menu() -> void:
	var show_transition = menu_displayer.currently_open_screen == menu_displayer.get_screen_from_name(MenuDisplayer.ScreenName.MainMenu)
	menu_displayer.open_screen(MenuDisplayer.ScreenName.SettingsMenu)
	
	if show_transition:
		handle_main_menu_to_settings_transition()

func handle_back_button_pressed() -> void:
	if !game_started:
		show_main_menu()
	else:
		show_paused_menu()
	
func show_main_menu() -> void:
	menu_displayer.open_screen(MenuDisplayer.ScreenName.MainMenu)
	if !game_started:
		handle_settings_to_main_menu_transition()
	game_started = false

func handle_game_started() -> void:
	show_game_ui()
	game_started = true
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") && !main_menu.visible && !settings_menu.visible:
		GameStateManager.toggle_pause()
		
		if get_tree().paused:
			show_paused_menu()
		else: 
			show_game_ui()
		

func show_game_ui() -> void:
	menu_displayer.open_screen(MenuDisplayer.ScreenName.HUD)
	
func show_paused_menu() -> void:
	menu_displayer.open_screen(MenuDisplayer.ScreenName.PauseMenu)
	
func end_credits() -> void:
	menu_displayer.open_screen(MenuDisplayer.ScreenName.CreditScreen)
	DialogueSystem.hide()
	
func show_wasted_screen() -> void:
	menu_displayer.open_screen(MenuDisplayer.ScreenName.WastedScreen)
	
func handle_main_menu_to_settings_transition() -> void:
	main_menu.show()
	schmear_frame.show()
	
	var main_menu_exit_tween: Tween = create_tween()
	main_menu_exit_tween.tween_property(main_menu, 'position', Vector2(main_menu.position.x + 1920 , main_menu.position.y), 0.3)
	main_menu_exit_tween.finished.connect(func(): 
		main_menu.hide()
		schmear_frame.hide())

	var settings_enter_tween: Tween = create_tween()
	settings_enter_tween.tween_property(settings_menu, 'position', Vector2(settings_menu.position.x - 1920, settings_menu.position.y),0)
	settings_enter_tween.tween_property(settings_menu, 'position', Vector2(0, settings_menu.position.y),0.3)
	
func handle_settings_to_main_menu_transition() -> void:
	schmear_frame.show()
	main_menu.show()
	var settings_menu_exit_tween: Tween = create_tween()
	settings_menu_exit_tween.tween_property(settings_menu, 'position', Vector2(settings_menu.position.x - 1920 , settings_menu.position.y), 0.3).set_ease(Tween.EASE_IN_OUT)
	settings_menu_exit_tween.finished.connect(func(): 
		settings_menu.hide()
		schmear_frame.hide()
		)
			
	var main_menu_enter_tween: Tween = create_tween()
	main_menu_enter_tween.tween_property(main_menu, 'position', Vector2(main_menu.position.x + 1920, main_menu.position.y),0)
	main_menu_enter_tween.tween_property(main_menu, 'position', Vector2(main_menu.position.x - 1920, main_menu.position.y),0.3).set_ease(Tween.EASE_IN_OUT)
	
