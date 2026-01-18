extends GameScreen
class_name WastedScreen

signal on_continued()

func _unhandled_key_input(event: InputEvent) -> void:
	if !visible:  return
	if event.is_action_pressed("roll"):
		GameStateManager.unpause_game()
		GameStateManager.reset_level()
		on_continued.emit()
		hide()

func open() -> void:
	show()
	
func close() -> void:
	hide()
