extends Node
@onready var main_menu: MainMenu = %MainMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var credits_screen: CreditScreen = %CreditScreen
@onready var hud: HUD = %HUD
@onready var menu_displayer: Control = %MenuDisplayer
@onready var dialogue_system: Control = %DialogueSystem
@onready var schmear_frame: TextureRect = %SchmearFrame
@export var default_font_theme: Theme
@export var readability_font_theme: Theme

var game_started: bool = false

func _ready() -> void:
	main_menu.settings_menu_button_pressed.connect(handle_setting_menu_opened)
	main_menu.start_button_pressed.connect(handle_game_started)
	GameStateManager.on_unpaused.connect(show_game_ui)
	GameStateManager.show_credits.connect(end_credits)
	UserSettings.on_font_toggled.connect(switch_font)
	settings_menu.on_back.connect(handle_back_button_pressed)
	main_menu.start_button.grab_focus.call_deferred()
	
	pause_menu.on_main_menu_opened.connect(handle_main_menu_opened)
	pause_menu.on_restarted.connect(GameStateManager.reset_level)
	pause_menu.on_settings_opened.connect(handle_setting_menu_opened)
	
func switch_font(readability_font: bool) -> void:
	menu_displayer.theme = readability_font_theme if readability_font else default_font_theme
	menu_displayer.queue_redraw()
	
	dialogue_system.theme = readability_font_theme if readability_font else default_font_theme
	dialogue_system.queue_redraw()
	
	
func handle_setting_menu_opened() -> void:
	settings_menu.show()
	hud.hide()
	settings_menu.open(!game_started)
	pause_menu.hide()
	
	if !game_started:
		handle_main_menu_to_settings_transition()
	else:
		main_menu.hide()

func handle_back_button_pressed() -> void:
	if !game_started:
		handle_main_menu_opened()
	else:
		show_paused_menu()
	
func handle_main_menu_opened() -> void:
	main_menu.show()
	hud.hide()
	pause_menu.hide()
	main_menu.start_button.grab_focus.call_deferred()
	
	if !game_started:
		handle_settings_to_main_menu_transition()
	else:
		settings_menu.hide()
	game_started = false

func handle_game_started() -> void:
	main_menu.hide()
	settings_menu.hide()
	hud.show()
	pause_menu.hide()
	game_started = true
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") && !main_menu.visible && !settings_menu.visible:
		GameStateManager.toggle_pause()
		
		if get_tree().paused:
			show_paused_menu()
		else: 
			show_game_ui()
		
func show_settings_menu() -> void:
	main_menu.hide()
	settings_menu.show()
	hud.hide()
	pause_menu.hide()
	
func show_game_ui() -> void:
	main_menu.hide()
	settings_menu.hide()
	hud.show() 	
	pause_menu.hide()
	

func show_paused_menu() -> void:
	pause_menu.open()
	settings_menu.hide()
	hud.hide()
	
func end_credits() -> void:
	pause_menu.hide()
	settings_menu.hide()
	hud.hide()
	main_menu.hide()
	credits_screen.show()
	
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
	var settings_menu_exit_tween: Tween = create_tween()
	settings_menu_exit_tween.tween_property(settings_menu, 'position', Vector2(settings_menu.position.x - 1920 , settings_menu.position.y), 0.3).set_ease(Tween.EASE_IN_OUT)
	settings_menu_exit_tween.finished.connect(func(): 
		settings_menu.hide()
		schmear_frame.hide()
		)
			
	var main_menu_enter_tween: Tween = create_tween()
	main_menu_enter_tween.tween_property(main_menu, 'position', Vector2(main_menu.position.x + 1920, main_menu.position.y),0)
	main_menu_enter_tween.tween_property(main_menu, 'position', Vector2(main_menu.position.x - 1920, main_menu.position.y),0.3).set_ease(Tween.EASE_IN_OUT)
	
