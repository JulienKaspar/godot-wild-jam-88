extends MarginContainer
class_name MenuDisplayer

var game_screens: Array[GameScreen]
var currently_open_screen: GameScreen

enum ScreenName {
	SettingsMenu,
	MainMenu,
	HUD,
	PauseMenu,
	LoadingScreen,
	CreditScreen,
	WastedScreen
	}

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is GameScreen:
			var screen: GameScreen = child as GameScreen
			game_screens.append(screen)
	
	currently_open_screen = get_screen_from_name(ScreenName.MainMenu)

func close_all_screens() -> void:
	for screen in game_screens: 
		screen.close()

func open_screen(screen_name: ScreenName) -> void:
	close_all_screens()
	var screen_instance = get_screen_from_name(screen_name)
	screen_instance.open()
	currently_open_screen = screen_instance

func get_screen_from_name(screen_name: ScreenName) -> GameScreen:
	for screen in game_screens:
		if screen.name == StringName(ScreenName.keys()[screen_name]):
			return screen
	return null
